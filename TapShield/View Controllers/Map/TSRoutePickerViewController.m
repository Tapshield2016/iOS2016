//
//  TSRoutePickerViewController.m
//  TapShield
//
//  Created by Adam Share on 3/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRoutePickerViewController.h"
#import "TSNotifySelectionViewController.h"
#import "TSUtilities.h"

@interface TSRoutePickerViewController ()

@property (nonatomic, strong) MKDirections *directions;

@end

@implementation TSRoutePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _nextButton.enabled = NO;
    
    [_homeViewController.entourageManager addObserver:self forKeyPath:@"selectedRoute" options: 0  context: NULL];
    
    _hitTestView.sendToView = _homeViewController.view;
    
    _directionsTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Car", @"Walk"]];
    _directionsTypeSegmentedControl.tintColor = [TSColorPalette tapshieldBlue];
    [_directionsTypeSegmentedControl setSelectedSegmentIndex:0];
    
    _directionsTransportType = MKDirectionsTransportTypeAutomobile;
    [_directionsTypeSegmentedControl addTarget:self
                                        action:@selector(transportTypeSegmentedControlValueChanged:)
                              forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setTitleView:_directionsTypeSegmentedControl];
    
    _etaLabel.textColor = [TSColorPalette tapshieldBlue];
    _addressLabel.textColor = [TSColorPalette tapshieldBlue];
    [_addressLabel setAdjustsFontSizeToFitWidth:YES];
    [_etaLabel setAdjustsFontSizeToFitWidth:YES];
    
    [_homeViewController.entourageManager userSelectedDestination:_destinationMapItem forTransportType:_directionsTransportType];
    
    // Display user location and selected destination if present
    if (_homeViewController.entourageManager.destinationMapItem) {
        _homeViewController.isTrackingUser = NO;
        [self requestAndDisplayRoutesForSelectedDestination];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self drawerCanDragForMenu:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self drawerCanDragForMenu:YES];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    
    [super willMoveToParentViewController:parent];
    
    if (!parent) {
        [_homeViewController.entourageManager removeObserver:self forKeyPath:@"selectedRoute" context: NULL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO Route Changes

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    TSRouteOption *selectedRouteOption = [object valueForKeyPath:keyPath];
    if (!selectedRouteOption) {
        return;
    }
    
    
    NSString *formattedText = [NSString stringWithFormat:@"%@ - %@", [TSUtilities formattedDescriptiveStringForDuration:selectedRouteOption.route.expectedTravelTime], [TSUtilities fromattedStringForDistanceInUSStandard:selectedRouteOption.route.distance]];
    
    [_addressLabel setText:selectedRouteOption.route.name withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    [_etaLabel setText:formattedText withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
}


#pragma mark - UISegmentedControl event handlers

- (void)transportTypeSegmentedControlValueChanged:(id)sender {
    
    [_addressLabel setText:@"Re-routing" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    [_etaLabel setText:@"" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    
    switch ([_directionsTypeSegmentedControl selectedSegmentIndex]) {
            
        case 0:
            _directionsTransportType = MKDirectionsTransportTypeAutomobile;
            break;
            
        case 1:
            _directionsTransportType = MKDirectionsTransportTypeWalking;
            break;
            
        default:
            _directionsTransportType = MKDirectionsTransportTypeAny;
            break;
    }
    
    [_homeViewController.entourageManager userSelectedDestination:_destinationMapItem forTransportType:_directionsTransportType];
    [self requestAndDisplayRoutesForSelectedDestination];
}




#pragma mark - Route management and display methods

- (void)calculateETAForSelectedDestination:(void (^)(NSTimeInterval expectedTravelTime))completion {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:_homeViewController.entourageManager.destinationMapItem];
    [request setTransportType:_homeViewController.entourageManager.destinationTransportType];
    [request setRequestsAlternateRoutes:YES];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        
        if (!error) {
            NSLog(@"%@", response);
            completion(response.expectedTravelTime);
        }
        else {
            NSLog(@"%@", error);
            // May have gotten an error due to attempting walking directions over too far
            // a distance, retry with 'Any'.
            if ((error.code == MKErrorPlacemarkNotFound || error.code == MKErrorDirectionsNotFound) && _homeViewController.entourageManager.destinationTransportType == MKDirectionsTransportTypeWalking) {
                NSLog(@"Error with walking directions, trying again with 'Any'");
                _homeViewController.entourageManager.destinationTransportType = MKDirectionsTransportTypeAny;
                [self calculateETAForSelectedDestination:completion];
            }
        }
    }];
}

- (void)requestAndDisplayRoutesForSelectedDestination {
    
    _nextButton.enabled = NO;
    
    if (!_homeViewController.mapView.userLocationAnnotation || !_homeViewController.entourageManager.destinationAnnotation) {
        return;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self showAnnotationsWithPadding:@[_homeViewController.mapView.userLocationAnnotation, _homeViewController.entourageManager.destinationAnnotation]];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:_homeViewController.entourageManager.destinationMapItem];
    [request setTransportType:_homeViewController.entourageManager.destinationTransportType]; // This can be limited to automobile and walking directions.
    [request setRequestsAlternateRoutes:YES]; // Gives you several route options.
    
    if (_directions.isCalculating) {
        [_directions cancel];
    }
    
    _homeViewController.entourageManager.selectedRoute = nil;
    [_homeViewController.entourageManager removeRouteOverlaysAndAnnotations];
    
    _directions = [[MKDirections alloc] initWithRequest:request];
    [_directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (!error) {
            _homeViewController.entourageManager.routes = [response routes];
            [_homeViewController.entourageManager addRouteOverlaysToMapViewAndAnnotations];
            [self showAnnotationsWithPadding:_homeViewController.entourageManager.routingAnnotations];
            _nextButton.enabled = YES;
        }
        else {
            [_addressLabel setText:error.localizedDescription withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
            [_etaLabel setText:error.localizedFailureReason withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
        }
    }];
}



- (void)showAnnotationsWithPadding:(NSArray *)annotations {
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [_homeViewController.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(130, 60, 30, 60) animated:YES];
}


- (IBAction)nextViewController:(id)sender {
    
    if (!_homeViewController.entourageManager.selectedRoute) {
        return;
    }
    
    [self transitionNavigationBarAnimatedLeft];
    [self blackNavigationBar];
    UIViewController *viewController = [self pushViewControllerWithClass:[TSNotifySelectionViewController class] transitionDelegate:nil navigationDelegate:nil animated:YES];
    ((TSNotifySelectionViewController *)viewController).etaString = _etaLabel.text;
    ((TSNotifySelectionViewController *)viewController).addressString = _addressLabel.text;
    ((TSNotifySelectionViewController *)viewController).homeViewController = _homeViewController;
}
@end
