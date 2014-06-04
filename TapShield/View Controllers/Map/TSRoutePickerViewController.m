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

#define TUTORIAL_TITLE @"Next, choose a route"
#define TUTORIAL_MESSAGE @"Walking or Driving? Pick the route that best represents your intended journey. We'll automatically calculate and suggest an ETA."

static NSString * const TSRoutePickerViewControllerTutorialShow = @"TSRoutePickerViewControllerTutorialShow";

@interface TSRoutePickerViewController ()

@property (nonatomic, strong) MKDirections *directions;
@property (nonatomic, strong) TSPopUpWindow *tutorialWindow;

@end

@implementation TSRoutePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _nextButton.enabled = NO;
    
    [[TSVirtualEntourageManager sharedManager].routeManager addObserver:self forKeyPath:@"selectedRoute" options: 0  context: NULL];
    
    _hitTestView.sendToView = _homeViewController.view;
    
    _directionsTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"Car"], [UIImage imageNamed:@"Walk"]]];
    _directionsTypeSegmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width/3, self.navigationController.navigationBar.frame.size.height - 10);
    [_directionsTypeSegmentedControl setApportionsSegmentWidthsByContent:NO];
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
    
    [[TSVirtualEntourageManager sharedManager].routeManager userSelectedDestination:_destinationMapItem forTransportType:_directionsTransportType];
    
    // Display user location and selected destination if present
    if ([TSVirtualEntourageManager sharedManager].routeManager.destinationMapItem) {
        _homeViewController.isTrackingUser = NO;
        [self requestAndDisplayRoutesForSelectedDestination];
    }
    
    [self showTutorial];
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
        [[TSVirtualEntourageManager sharedManager].routeManager removeObserver:self forKeyPath:@"selectedRoute" context: NULL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showTutorial {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:TSRoutePickerViewControllerTutorialShow]) {
        return;
    }
    
    _tutorialWindow = [[TSPopUpWindow alloc] initWithRepeatCheckBox:TSRoutePickerViewControllerTutorialShow
                                                              title:TUTORIAL_TITLE
                                                            message:TUTORIAL_MESSAGE];
    [_tutorialWindow show];
}


#pragma mark - KVO Route Changes

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    TSRouteOption *selectedRouteOption = [object valueForKeyPath:keyPath];
    if (!selectedRouteOption) {
        return;
    }
    
    
    NSString *formattedText = [NSString stringWithFormat:@"%@ - %@", [TSUtilities formattedDescriptiveStringForDuration:selectedRouteOption.route.expectedTravelTime], [TSUtilities formattedStringForDistanceInUSStandard:selectedRouteOption.route.distance]];
    
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
    
    [[TSVirtualEntourageManager sharedManager].routeManager userSelectedDestination:_destinationMapItem forTransportType:_directionsTransportType];
    [self requestAndDisplayRoutesForSelectedDestination];
}




#pragma mark - Route management and display methods

- (void)requestAndDisplayRoutesForSelectedDestination {
    
    _nextButton.enabled = NO;
    
    if (!_homeViewController.mapView.userLocationAnnotation || ![TSVirtualEntourageManager sharedManager].routeManager.destinationAnnotation) {
        return;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self showAnnotationsWithPadding:@[_homeViewController.mapView.userLocationAnnotation, [TSVirtualEntourageManager sharedManager].routeManager.destinationAnnotation]];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:[TSVirtualEntourageManager sharedManager].routeManager.destinationMapItem];
    [request setTransportType:[TSVirtualEntourageManager sharedManager].routeManager.destinationTransportType]; // This can be limited to automobile and walking directions.
    [request setRequestsAlternateRoutes:YES]; // Gives you several route options.
    
    if (_directions.isCalculating) {
        [_directions cancel];
    }
    
    [TSVirtualEntourageManager sharedManager].routeManager.selectedRoute = nil;
    [[TSVirtualEntourageManager sharedManager].routeManager removeRouteOverlaysAndAnnotations];
    
    _directions = [[MKDirections alloc] initWithRequest:request];
    [_directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (!error) {
            [TSVirtualEntourageManager sharedManager].routeManager.routes = [response routes];
            [[TSVirtualEntourageManager sharedManager].routeManager addRouteOverlaysToMapViewAndAnnotations];
            [self showAnnotationsWithPadding:[TSVirtualEntourageManager sharedManager].routeManager.routingAnnotations];
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
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [_homeViewController.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(130, 60, 30, 60) animated:YES];
}


- (IBAction)nextViewController:(id)sender {
    
    if (![TSVirtualEntourageManager sharedManager].routeManager.selectedRoute) {
        return;
    }
    
    [self transitionNavigationBarAnimatedLeft];
    [self blackNavigationBar];
    UIViewController *viewController = [self pushViewControllerWithClass:[TSNotifySelectionViewController class] transitionDelegate:nil navigationDelegate:nil animated:YES];
    
    ((TSNotifySelectionViewController *)viewController).keyValueObserver = self;
    ((TSNotifySelectionViewController *)viewController).homeViewController = _homeViewController;
}
@end
