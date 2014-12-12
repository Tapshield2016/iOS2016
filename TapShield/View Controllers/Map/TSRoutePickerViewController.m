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
#import <KVOController/FBKVOController.h>

#define TUTORIAL_TITLE @"Next, choose a route"
#define TUTORIAL_MESSAGE @"Walking or Driving? Pick the route that best represents your intended journey. We'll automatically calculate and suggest an ETA."

static NSString * const TSRoutePickerViewControllerTutorialShow = @"TSRoutePickerViewControllerTutorialShow";
static NSString * const TSRoutePickerViewControllerTravelType = @"TSRouteTravelType";

@interface TSRoutePickerViewController ()


@property (nonatomic, strong) TSPopUpWindow *tutorialWindow;
@property (nonatomic, strong) FBKVOController *kvoController;

@property (nonatomic, strong) UIImageView *centerPin;

@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation TSRoutePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    [self monitorSelectedRoute];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeRegion) name:TSMapViewDidChangeRegion object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeRegion) name:TSMapViewWillChangeRegion object:nil];
    
    [TSEntourageSessionManager sharedManager].routeManager.destinationMapItem = nil;
    
    [_homeViewController setIsTrackingUser:NO animateToUser:NO];
    
    _nextButton.enabled = NO;
    
    _hitTestView.sendToView = _homeViewController.view;
    
    _directionsTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"Walk"], [UIImage imageNamed:@"Car"]]];
    _directionsTypeSegmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width/3, self.navigationController.navigationBar.frame.size.height - 10);
    [_directionsTypeSegmentedControl setApportionsSegmentWidthsByContent:NO];
    _directionsTypeSegmentedControl.tintColor = [TSColorPalette tapshieldBlue];
    
    
    [TSEntourageSessionManager sharedManager].routeManager.destinationTransportType = [[NSUserDefaults standardUserDefaults] integerForKey:TSRoutePickerViewControllerTravelType];
    [_directionsTypeSegmentedControl setSelectedSegmentIndex:self.directionsTransportType];
    
    
    [_directionsTypeSegmentedControl addTarget:self
                                        action:@selector(transportTypeSegmentedControlValueChanged:)
                              forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setTitleView:_directionsTypeSegmentedControl];
    
    _etaLabel.textColor = [TSColorPalette tapshieldBlue];
    _addressLabel.textColor = [TSColorPalette tapshieldBlue];
    [_addressLabel setAdjustsFontSizeToFitWidth:YES];
    [_etaLabel setAdjustsFontSizeToFitWidth:YES];
    
    // Display user location and selected destination if present
    if ([TSEntourageSessionManager sharedManager].routeManager.destinationMapItem) {
        [_homeViewController setIsTrackingUser:NO animateToUser:NO];
        [self requestAndDisplayRoutesForSelectedDestination];
    }
    
    [self showTutorial];
    [self setCenterPinType:self.directionsTransportType];
}

- (void)setCenterPinType:(MKDirectionsTransportType)type {
    
    UIImage *image;
    
    if (type == MKDirectionsTransportTypeWalking) {
        image = [UIImage imageNamed:@"WalkEndPoint"];
    }
    else {
        image = [UIImage imageNamed:@"CarEndPoint"];
    }
    
    if (!_centerPin) {
        _centerPin = [[UIImageView alloc] initWithImage:image];
        [self.view addSubview:_centerPin];
        _centerPin.center = CGPointMake(_homeViewController.mapView.contentCenter.x, _homeViewController.mapView.contentCenter.y+12);
    }
    else {
        _centerPin.image = image;
    }
}

- (MKDirectionsTransportType)directionsTransportType {
    
    return [TSEntourageSessionManager sharedManager].routeManager.destinationTransportType;
}

- (void)setDirectionsTransportType:(MKDirectionsTransportType) type {
    
    [TSEntourageSessionManager sharedManager].routeManager.destinationTransportType = type;
    [self setCenterPinType:type];
}

- (void)showCenterPin:(BOOL)show {
    
    [_centerPin setHidden:!show];
}

//- (void)monitorSelectedRoute {
//
//    _kvoController = [FBKVOController controllerWithObserver:self];
//
//    [_kvoController observe:[TSEntourageSessionManager sharedManager].routeManager keyPath:@"selectedRoute" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(TSRoutePickerViewController *weakSelf, TSRouteManager *routeManager, NSDictionary *change) {
//
//        if (!routeManager.selectedRoute) {
//            return;
//        }
//
//        NSString *formattedText = [NSString stringWithFormat:@"%@ - %@", [TSUtilities formattedDescriptiveStringForDuration:routeManager.selectedRoute.expectedTravelTime], [TSUtilities formattedStringForDistanceInUSStandard:routeManager.selectedRoute.distance]];
//
//        [weakSelf.addressLabel setText:routeManager.selectedRoute.name withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
//        [weakSelf.etaLabel setText:formattedText withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
//    }];
//}

//- (void)monitorDestinationMapItem {
//
//    _kvoController = [FBKVOController controllerWithObserver:self];
//
//    [_kvoController observe:[TSEntourageSessionManager sharedManager].routeManager keyPath:@"destinationMapItem" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(TSRoutePickerViewController *weakSelf, TSRouteManager *routeManager, NSDictionary *change) {
//
//        if (!routeManager.destinationMapItem) {
//            return;
//        }
//
//        [self requestAndDisplayRoutesForSelectedDestination];
//    }];
//}

- (void)setDestinationMapItem:(MKMapItem *)destinationMapItem {
    
    _destinationMapItem = destinationMapItem;
    
    [[TSEntourageSessionManager sharedManager].routeManager userSelectedDestination:_destinationMapItem forTransportType:self.directionsTransportType];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self drawerCanDragForMenu:NO];
    [self drawerCanDragForContacts:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self drawerCanDragForMenu:YES];
    [self drawerCanDragForContacts:YES];
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


#pragma mark - UISegmentedControl event handlers

- (void)transportTypeSegmentedControlValueChanged:(id)sender {
    
    [_addressLabel setText:@"Re-calculating" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    [_etaLabel setText:@"" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    
    switch ([_directionsTypeSegmentedControl selectedSegmentIndex]) {
            
        case 0:
            [self setDirectionsTransportType:MKDirectionsTransportTypeWalking];
            break;
            
        case 1:
            [self setDirectionsTransportType:MKDirectionsTransportTypeAutomobile];
            break;
            
        default:
            [self setDirectionsTransportType:MKDirectionsTransportTypeAny];
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.directionsTransportType forKey:TSRoutePickerViewControllerTravelType];
    
    [self updateRoutes];
    [[TSEntourageSessionManager sharedManager].routeManager updateTempMapItemTransportType];
}




#pragma mark - Route management and display methods

- (void)requestAndDisplayRoutesForSelectedDestination {
    
    _nextButton.enabled = NO;
    
    [[TSEntourageSessionManager sharedManager].routeManager getRoutesForDestination:^(TSRouteOption *bestRoute, NSError *error) {
        if (!error) {
            [self showCenterPin:NO];
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
    
    if (![TSEntourageSessionManager sharedManager].routeManager.selectedRoute) {
        return;
    }
    
    [self transitionNavigationBarAnimatedLeft];
    [self blackNavigationBar];
    UIViewController *viewController = [self pushViewControllerWithClass:[TSNotifySelectionViewController class] transitionDelegate:nil navigationDelegate:nil animated:YES];
    
    ((TSNotifySelectionViewController *)viewController).keyValueObserver = self;
    ((TSNotifySelectionViewController *)viewController).homeViewController = _homeViewController;
}


- (IBAction)dismissViewController:(id)sender {
    
    [_homeViewController beginAppearanceTransition:YES animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
        [_homeViewController endAppearanceTransition];
        [[TSEntourageSessionManager sharedManager] stopEntourage];
    }];
}


#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    //    if (gestureRecognizer == _pinchGesture && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
    //        return NO;
    //    }
    //
    //    if (gestureRecognizer == _panGesture && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
    //        return NO;
    //    }
    
    return YES;
}

- (void)willChangeRegion {
    
    [_geocoder cancelGeocode];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didChangeRegion {
    
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    [_geocoder cancelGeocode];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_homeViewController.mapView.centerCoordinate.latitude longitude:_homeViewController.mapView.centerCoordinate.longitude];
    
    if ([location distanceFromLocation:[TSEntourageSessionManager sharedManager].routeManager.destinationMapItem.placemark.location] < 20 && [TSEntourageSessionManager sharedManager].routeManager.destinationMapItem.placemark.location) {
        [[TSEntourageSessionManager sharedManager].routeManager updateTempMapItemLocation:location];
        return;
    }
    
    [self performSelector:@selector(routeLocation:) withObject:location afterDelay:1.0];
}

- (void)routeLocation:(CLLocation *)location {
    
    NSLog(@"Searching location %@", location);
    
    [_addressLabel setText:@"Searching" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    [_etaLabel setText:@"" withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    
    [[TSEntourageSessionManager sharedManager].routeManager cancelSearch];
    
    [_geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error){
        CLPlacemark *placemark = placemarks[0];
        NSLog(@"Found %@", placemark.name);
        
        if (placemark) {
            
            [TSEntourageSessionManager sharedManager].routeManager.destinationMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:placemark.addressDictionary]];
            [_addressLabel setText:[TSEntourageSessionManager sharedManager].routeManager.destinationMapItem.name withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
            [_etaLabel setText:@"Routing..." withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
            [self updateRoutes];
        }
    }];
}

- (void)updateRoutes {
    
    [[TSEntourageSessionManager sharedManager].routeManager getRoutesForDestination:^(TSRouteOption *bestRoute, NSError *error) {
        
        NSString *formattedText = [NSString stringWithFormat:@"%@ - %@", [TSUtilities formattedDescriptiveStringForDuration:bestRoute.expectedTravelTime], [TSUtilities formattedStringForDistanceInUSStandard:bestRoute.distance]];
        [_etaLabel setText:formattedText withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    }];
}

@end
