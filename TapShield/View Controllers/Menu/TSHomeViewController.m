//
//  TSHomeViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHomeViewController.h"
#import "TSDestinationSearchViewController.h"
#import "TSNotifySelectionViewController.h"
#import <MapKit/MapKit.h>
#import "TSSelectedDestinationLeftCalloutAccessoryView.h"
#import "TSUtilities.h"
#import "TSIntroPageViewController.h"
#import "TSRouteTimeAnnotationView.h"
#import "TSOrganizationAnnotationView.h"
#import "TSUserAnnotationView.h"
#import "TSDestinationAnnotationView.h"
#import "TSPageViewController.h"
#import "TSAlertDetailsTableViewController.h"
#import "TSYankManager.h"
#import "TSSpotCrimeAPIClient.h"
#import "TSSpotCrimeAnnotationView.h"
#import "TSGeofence.h"
#import "TSViewReportDetailsViewController.h"
#import "TSClusterAnnotationView.h"
#import "TSHeatMapOverlay.h"
#import "ADClusterAnnotation.h"
#import <KVOController/FBKVOController.h>
#import <LocalAuthentication/LocalAuthentication.h>

static NSString * const kYankHintOff = @"To activate yank, select button and insert headphones.  When headphones are yanked from the headphone jack, you will have 10 seconds to disarm before an alert is sent";
static NSString * const kYankHintOn = @"To disable yank, select button, and when notified, you may remove your headphones";


@interface TSHomeViewController ()


@property (nonatomic, strong) TSTopDownTransitioningDelegate *topDownTransitioningDelegate;
@property (nonatomic, strong) TSBottomUpTransitioningDelegate *bottomUpTransitioningDelegate;
@property (nonatomic, strong) TSTransformCenterTransitioningDelegate *transformCenterTransitioningDelegate;
@property (strong, nonatomic) FBKVOController *KVOController;
@property (nonatomic) BOOL viewDidAppear;
@property (strong, nonatomic) TSBaseLabel *timerLabel;
@property (assign, nonatomic) BOOL annotationsLoaded;
@property (assign, nonatomic) BOOL firstMapLoad;
@property (assign, nonatomic) BOOL locationServicesWereDisabled;
@property (strong, nonatomic) UIAlertController *cancelEntourageAlertController;

@property (strong, nonatomic) TSBottomMapButton *policeButton;
@property (strong, nonatomic) TSBottomMapButton *emergencyButton;
@property (strong, nonatomic) TSBottomMapButton *chatButton;

@end

@implementation TSHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _firstMapLoad = YES;
    [self setIsTrackingUser:YES animateToUser:NO];
    _statusView.hidden = YES;
    
    _annotationsLoaded = NO;
    
    self.showSmallLogoInNavBar = YES;
    _mapView.isAnimatingToRegion = YES;
    
    [[TSAlertManager sharedManager] setCurrentHomeViewController:self];
    
    _reportManager = [[TSReportAnnotationManager alloc] initWithMapView:_mapView];
    
    [TSVirtualEntourageManager initSharedEntourageManagerWithHomeView:self];

    // Tap recognizer for selecting routes and other items
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [_mapView addGestureRecognizer:recognizer];

    _geocoder = [[CLGeocoder alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mapAlertModeToggle)
                                                 name:TSJavelinAlertManagerDidDisarmNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mapAlertModeToggle)
                                                 name:TSJavelinAlertManagerDidRecieveActiveAlertNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendYankAlert)
                                                 name:TSYankManagerDidYankHeadphonesNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendEntourageAlert)
                                                 name:TSVirtualEntourageManagerTimerDidEnd
                                               object:nil];
    
    _statusViewHeight.constant = 0;
    
    [[TSLocationController sharedLocationController] bestAccuracyRefresh];
    
    [self initCallChatButtons];
    
    if ([TSYankManager sharedYankManager].isEnabled) {
        UIImage *image = [_yankButton imageForState:UIControlStateNormal];
        [_yankButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_yankButton setTintColor:[TSColorPalette alertRed]];
        _yankButton.layer.borderColor = [TSColorPalette alertRed].CGColor;
        _yankButton.accessibilityValue = @"On";
        _yankButton.accessibilityHint = kYankHintOn;
    }
    else {
        _yankButton.accessibilityValue = @"Off";
        _yankButton.accessibilityHint = kYankHintOff;
    }
    
    [_helpButton setImage:[[UIImage alloc] init] forState:UIControlStateSelected];
    [_helpButton setImage:[[UIImage alloc] init] forState:UIControlStateSelected|UIControlStateHighlighted];
    [_helpButton setTitle:@"X" forState:UIControlStateSelected|UIControlStateHighlighted];
    [_helpButton setLabelTitle:@"Help"];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    _mapView.isAnimatingToRegion = YES;
    [_mapView removeAnimatedOverlay];
    
    if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser]) {
        [self addOverlaysAndAnnotations];
    }
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if ([TSJavelinAPIClient loggedInUser]) {
        [self whiteNavigationBar];
    }
    
    _mapView.isAnimatingToRegion = NO;
    
    [_mapView resetAnimatedOverlayAt:[TSLocationController sharedLocationController].location];
    
    [self showAllSubviews];
    
    if (_viewDidAppear) {
        [self performSelector:@selector(geocoderUpdateUserLocationAnnotationCallOutForLocation:)
                   withObject:[TSLocationController sharedLocationController].location
                   afterDelay:0.5];
    }
    
    //To determine animation of first region
    _viewDidAppear = YES;
    
    if (_firstMapLoad) {
        _firstMapLoad = NO;
        [_mapView setRegionAtAppearanceAnimated:YES];
    }
    
    if ([TSAlertManager sharedManager].isPresented) {
        [[TSAlertManager sharedManager] setCurrentHomeViewController:self];
        _mapView.shouldUpdateCallOut = YES;
        [self showOnlyMap];
        [_reportManager hideSpotCrimes];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self setStatusViewText:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    [_reportManager removeOldSpotCrimes];
}


#pragma mark - Map Setup

- (void)addOverlaysAndAnnotations {
    
    [TSLocationController sharedLocationController].delegate = self;
    if (!_annotationsLoaded) {
        
        [_mapView refreshRegionBoundariesOverlay];
        
        __weak __typeof(self)weakSelf = self;
        [[TSLocationController sharedLocationController] startStandardLocationUpdates:^(CLLocation *location) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.annotationsLoaded = YES;
            [[TSLocationController sharedLocationController].geofence updateNearbyAgencies];
            [strongSelf.reportManager performSelector:@selector(loadSpotCrimeAndSocialAnnotations:) withObject:location afterDelay:2.0];
            [strongSelf addUserLocationAnnotation:location];
            [strongSelf geocoderUpdateUserLocationAnnotationCallOutForLocation:location];
        }];
    }
}

- (void)addUserLocationAnnotation:(CLLocation *)location {
    
    if (!_mapView.userLocationAnnotation) {
        
        // create KVO controller with observer
        FBKVOController *KVOController = [FBKVOController controllerWithObserver:_mapView];
        
        // add strong reference from observer to KVO controller
        _KVOController = KVOController;
        
        [_KVOController observe:[TSJavelinAPIClient loggedInUser].userProfile
                        keyPath:@"profileImage"
                        options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(TSMapView *mapView, TSJavelinAPIUserProfile *userProfile, NSDictionary *change) {
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                
                                [mapView removeAnnotation:mapView.userLocationAnnotation];
                                
                                mapView.userLocationAnnotation = [[TSUserLocationAnnotation alloc] initWithCoordinates:location.coordinate
                                                                                                              placeName:nil
                                                                                                            description:nil];
                                
                                [mapView addAnnotation:mapView.userLocationAnnotation];
                                [mapView updateAccuracyCircleWithLocation:location];
                            }];
                        }];
    }
}

#pragma mark - Entourage Timer

- (void)adjustViewableTime {
    
    if (!_clockTimer) {
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(adjustViewableTime)
                                                     userInfo:nil
                                                      repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_clockTimer forMode:NSRunLoopCommonModes];
    }
    
    NSDate *fireDate = [TSVirtualEntourageManager sharedManager].endTimer.fireDate;
    
    NSTimeInterval time = [fireDate timeIntervalSinceDate:[NSDate date]];
    
    if (!_timerLabel) {
        [self.navigationItem setPrompt:@""];
        _timerLabel = [[TSBaseLabel alloc] init];
        _timerLabel.textColor = [TSColorPalette tapshieldBlue];
        _timerLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
        _timerLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationController.navigationBar addSubview:_timerLabel];
    }
    
    _timerLabel.text = [TSUtilities formattedStringForTime:time];
    [_timerLabel setNeedsDisplay];
}

- (void)stopClockTimer {
    
    [_clockTimer invalidate];
    _clockTimer = nil;
    
    self.navigationController.navigationBar.topItem.prompt = nil;
    
    [_timerLabel removeFromSuperview];
    _timerLabel = nil;
}

#pragma mark - UI Changes

- (void)mapAlertModeToggle {
    
    [_mapView updateAccuracyCircleWithLocation:[TSLocationController sharedLocationController].location];
    [_mapView resetAnimatedOverlayAt:[TSLocationController sharedLocationController].location];
}

- (void)entourageModeOn {
    
    [_reportManager showSpotCrimes];
    [self setIsTrackingUser:YES animateToUser:YES];
    [self drawerCanDragForMenu:NO];
    [self adjustViewableTime];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"End Tracking" style:UIBarButtonItemStylePlain target:self action:@selector(cancelEntourage)];
    [barButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue],
                                        NSFontAttributeName :[TSFont fontWithName:kFontWeightLight size:17.0f]} forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:barButton animated:YES];
}

- (void)clearEntourageAndResetMap {
    
    [_reportManager showSpotCrimes];
    [_menuViewController showMenuButton:self];
    [[TSVirtualEntourageManager sharedManager] stopEntourage];
    [self drawerCanDragForMenu:YES];
    
    [self stopClockTimer];
}


#pragma mark - Home Screen Buttons

- (void)cancelEntourage {
    
    if ([self touchIDAvailable]) {
        [self useTouchID];
    }
    else {
        [self enterPasscodeCancel];
    }
}

- (void)enterPasscodeCancel {
    
    _cancelEntourageAlertController = [UIAlertController alertControllerWithTitle:@"Stop Entourage"
                                                                          message:@"Please enter passcode"
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self)weakSelf = self;
    [_cancelEntourageAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"1234"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setSecureTextEntry:YES];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [textField setDelegate:weakSelf];
    }];
    [_cancelEntourageAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:_cancelEntourageAlertController animated:YES completion:nil];
}

- (void)showEntourageMembers:(id)sender {
    
    
}

- (void)sendYankAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_yankButton setTintColor:[TSColorPalette blueButtonColor]];
        _yankButton.layer.borderColor = [TSColorPalette tapshieldBlue].CGColor;
        _yankButton.accessibilityValue = @"Off";
        _yankButton.accessibilityHint = kYankHintOff;
    }];
    
    [self transitionForAlert];
    [[TSAlertManager sharedManager] startYankAlertCountdown];
}

- (void)sendEntourageAlert {
    
    [self transitionForAlert];
    [[TSAlertManager sharedManager] startEntourageAlertCountdown];
}

- (IBAction)sendAlert:(id)sender {
    
    _helpButton.selected = !_helpButton.selected;
    
    if (_helpButton.selected) {
        [self showCallChatButtons];
    }
    else {
        [self hideCallChatButtons];
    }
}

- (void)transitionForAlert {
    
    if ([TSAlertManager sharedManager].isPresented) {
        return;
    }
    
    _mapView.shouldUpdateCallOut = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        _mapView.shouldUpdateCallOut = YES;
        [self showOnlyMap];
        [_reportManager hideSpotCrimes];
        
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
        
        [self showOnlyMap];
        [_reportManager hideSpotCrimes];
    });
}

- (IBAction)openEntourage:(id)sender {
    
    [_reportManager hideSpotCrimes];
    
    
    if (!_topDownTransitioningDelegate) {
        _topDownTransitioningDelegate = [[TSTopDownTransitioningDelegate alloc] init];
    }
    
    if (![TSVirtualEntourageManager sharedManager].isEnabled) {
        TSDestinationSearchViewController *viewController = (TSDestinationSearchViewController *)[self presentViewControllerWithClass:[TSDestinationSearchViewController class] transitionDelegate:_topDownTransitioningDelegate animated:YES];
        viewController.homeViewController = self;
        
        [self showOnlyMap];
    }
    else {
        
        TSNotifySelectionViewController *viewController = (TSNotifySelectionViewController *)[self presentViewControllerWithClass:[TSNotifySelectionViewController class] transitionDelegate:_topDownTransitioningDelegate animated:YES];
        viewController.homeViewController = self;
    }
}

- (IBAction)reportAlert:(id)sender {
    
    TSAlertDetailsTableViewController *viewController = (TSAlertDetailsTableViewController *)[self presentViewControllerWithClass:[TSAlertDetailsTableViewController class] transitionDelegate:nil animated:YES];
    
    viewController.reportManager = _reportManager;
}

- (IBAction)toggleYank:(id)sender {
    
    [[TSYankManager sharedYankManager] enableYank:^(BOOL enabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (enabled) {
                
                UIImage *image = [_yankButton imageForState:UIControlStateNormal];
                [_yankButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [_yankButton setTintColor:[TSColorPalette alertRed]];
                _yankButton.layer.borderColor = [TSColorPalette alertRed].CGColor;
                _yankButton.accessibilityValue = @"On";
                _yankButton.accessibilityHint = kYankHintOn;
            }
            else {
                [_yankButton setTintColor:[TSColorPalette blueButtonColor]];
                _yankButton.layer.borderColor = [TSColorPalette tapshieldBlue].CGColor;
                _yankButton.accessibilityValue = @"Off";
                _yankButton.accessibilityHint = kYankHintOff;
            }
        });
    }];
}

- (IBAction)userLocationTUI:(id)sender {
    
    [self setIsTrackingUser:YES animateToUser:YES];
    
    [[TSLocationController sharedLocationController] bestAccuracyRefresh];
}

- (void)setIsTrackingUser:(BOOL)isTrackingUser animateToUser:(BOOL)animate {
    
    _isTrackingUser = isTrackingUser;
    _showUserLocationButton.selected = isTrackingUser;
    
    if (isTrackingUser && animate) {
        if (_mapView.region.span.latitudeDelta > 0.1f) {
            [_mapView setRegionAtAppearanceAnimated:YES];
        }
        else if (animate) {
            [_mapView setCenterCoordinate:[TSLocationController sharedLocationController].location.coordinate animated:_viewDidAppear];
        }
        
        [self geocoderUpdateUserLocationAnnotationCallOutForLocation:[TSLocationController sharedLocationController].location];
    }
}

- (void)showAllSubviews {
    
    _statusView.alpha = 1.0;
    
    [UIView animateWithDuration:0.3f animations:^{
        for (UIView *view in self.view.subviews) {
            view.alpha = 1.0f;
        }
    }];
}

- (void)showOnlyMap {
    
    [UIView animateWithDuration:0.3f animations:^{
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[MKMapView class]]) {
                continue;
            }
            
            view.alpha = 0.0f;
        }
    }];
}


- (void)setStatusViewText:(NSString *)string {
    
    [_statusView setText:string];
    
    float height = _statusView.originalHeight;
    
    if (!string) {
        height = 0;
    }
    
    if (_statusViewHeight.constant == height) {
        return;
    }
    
    if (self.navigationController.navigationBarHidden) {
        return;
    }
    else {
        _statusView.hidden = NO;
    }
    
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction | UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            _statusViewHeight.constant = height;
            
            [self.view layoutIfNeeded];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            if (!height) {
                _statusView.hidden = YES;
            }
        }];
        
         } completion:nil];
    
//    [UIView animateWithDuration:0.3
//                          delay:0
//         usingSpringWithDamping:300.0
//          initialSpringVelocity:5.0
//                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                         _statusViewHeight.constant = height;
//                         
//                         [self.view layoutIfNeeded];
//                     } completion:^(BOOL finished) {
//                         if (!height) {
//                             _statusView.hidden = YES;
//                         }
//                     }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Gesture handlers

- (void)userDidPanMapView:(ADClusterMapView *)mapView {
    
}

- (void)userWillPanMapView:(ADClusterMapView *)mapView {
    
    [self setIsTrackingUser:NO animateToUser:NO];
    [self setStatusViewText:nil];
}

- (void)handleTap:(UIGestureRecognizer *)recognizer {
    
    if ([TSVirtualEntourageManager sharedManager].isEnabled ) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        for (int i = 0; i < recognizer.numberOfTouches; i++) {
            CGPoint point = [recognizer locationOfTouch:i inView:_mapView];
            
            //If hitting Annotation don't test polyline proximity
            UIView *view = [_mapView hitTest:point withEvent:nil];
            if ([view isKindOfClass:[TSRouteTimeAnnotationView class]]) {
                return;
            }

            CLLocationCoordinate2D coord = [_mapView convertPoint:point toCoordinateFromView:_mapView];
            MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
            [[TSVirtualEntourageManager sharedManager].routeManager selectRouteClosestTo:mapPoint];
        }
    }
}




#pragma mark - TSLocationControllerDelegate methods

- (void)locationDidUpdate:(CLLocation *)location {
    
    if ([TSVirtualEntourageManager sharedManager].isEnabled) {
        [[TSVirtualEntourageManager sharedManager] checkRegion:location];
    }
    
    if (_mapView.userLocationAnnotation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapView updateAccuracyCircleWithLocation:location];
            _mapView.userLocationAnnotation.coordinate = location.coordinate;
        });
    }

    if (!_mapView.isAnimatingToRegion && _isTrackingUser) {
        //avoid loop from negligible differences in region change
        if (fabs(_mapView.region.center.latitude - location.coordinate.latitude) >= .0000001 ||
            fabs(_mapView.region.center.longitude - location.coordinate.longitude) >= .0000001) {
            [_mapView setCenterCoordinate:location.coordinate animated:_viewDidAppear];
        }
    }
    
    [self geocoderUpdateUserLocationAnnotationCallOutForLocation:location];
    
    _mapView.previousLocation = location;
    
    if (_viewDidAppear) {
        [_mapView resetAnimatedOverlayAt:location];
    }
}

- (void)didEnterRegion:(CLRegion *)region {
    
}

- (void)didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusDenied) {
        
        _locationServicesWereDisabled = YES;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location Services Disabled" message:@"\nFor the best experience using TapShield, enable location services.\n\n You can turn on location services by choosing 'Always' in \n\nSettings -> Privacy ->\nLocation Services" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [TSAppDelegate openSettings];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser] && _locationServicesWereDisabled) {
        _locationServicesWereDisabled = NO;
        [self addOverlaysAndAnnotations];
        [_mapView setRegionAtAppearanceAnimated:YES];
    }
}

#pragma mark - User Callout

- (void)geocoderUpdateUserLocationAnnotationCallOutForLocation:(CLLocation *)location {
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    
    BOOL search = NO;
    BOOL show = NO;
    
    if (_mapView.shouldUpdateCallOut || _isTrackingUser) {
        show = YES;
        if ([_mapView.lastReverseGeocodeLocation distanceFromLocation:location] > 10 ||
            !_mapView.lastReverseGeocodeLocation ||
            !_statusView.userLocation) {
            search = YES;
        }
    }
    
    if (search) {
        
        _mapView.lastReverseGeocodeLocation = location;
        
        [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if (error) {
                _mapView.lastReverseGeocodeLocation = nil;
            }
            
            if (placemarks) {
                CLPlacemark *placemark = [placemarks firstObject];
                NSString *title = @"";
                NSString *subtitle = @"";
                if (placemark.subThoroughfare) {
                    title = placemark.subThoroughfare;
                }
                if (placemark.thoroughfare) {
                    title = [NSString stringWithFormat:@"%@ %@", title, placemark.thoroughfare];
                }
                if (placemark.locality) {
                    subtitle = placemark.locality;
                }
                if (placemark.administrativeArea) {
                    if (placemark.locality) {
                        subtitle = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                    }
                    else {
                        subtitle = placemark.administrativeArea;
                    }
                }
                if (placemark.postalCode) {
                    subtitle = [NSString stringWithFormat:@"%@ %@", subtitle, placemark.postalCode];
                }
                
                if (!title || !title.length) {
                    title = subtitle;
                }
                
                _statusView.userLocation = [NSString stringWithFormat:@"%@", title];
                [self setStatusViewText:_statusView.userLocation];
                
                _mapView.userLocationAnnotation.title = [NSString stringWithFormat:@"Approx: %@", title];
//                _mapView.userLocationAnnotation.accessibilityLabel 
            }
            else {
                _statusView.userLocation = nil;
                [self setStatusViewText:@"Searching"];
            }
        }];
    }
    else if (show) {
        [self setStatusViewText:_statusView.userLocation];
    }
    
//    _mapView.userLocationAnnotation.title = [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude];
}

#pragma mark - MKMapViewDelegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if([overlay isKindOfClass:[MKPolygon class]]){
        
        return [TSMapView mapViewPolygonOverlay:overlay];
    }
    else if ([overlay isKindOfClass:[MKCircle class]] ||
             [overlay isKindOfClass:[TSHeatMapOverlay class]]) {
        
        return [TSMapView mapViewCircleOverlay:overlay];
    }
    else if ([overlay isKindOfClass:[MKPolyline class]]) {
        return [self rendererForRoutePolyline:overlay];
    }
    
    return nil;
}

- (MKPolylineRenderer *)rendererForRoutePolyline:(id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    [renderer setLineWidth:6.0];
    [renderer setStrokeColor:[TSColorPalette lightGrayColor]];
    
    if (![TSVirtualEntourageManager sharedManager].routeManager.selectedRoute) {
        [TSVirtualEntourageManager sharedManager].routeManager.selectedRoute = [[TSVirtualEntourageManager sharedManager].routeManager.routeOptions firstObject];
    }
    
    if ([TSVirtualEntourageManager sharedManager].routeManager.selectedRoute) {
        for (TSRouteOption *routeOption in [TSVirtualEntourageManager sharedManager].routeManager.routeOptions) {
            if (routeOption == [TSVirtualEntourageManager sharedManager].routeManager.selectedRoute) {
                if (routeOption.route.polyline == overlay) {
                    [renderer setStrokeColor:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.8]];
                    break;
                }
            }
        }
    }
    else {
        NSLog(@"No selected route right now");
    }
    
    return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    id annotationView;
    
    if ([annotation isKindOfClass:[TSUserLocationAnnotation class]]) {
        annotationView = (TSUserAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSUserAnnotationView class])];
        if (!annotationView) {
            annotationView = [[TSUserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSUserAnnotationView class])];
        }
        
        _mapView.userLocationAnnotationView = (TSUserAnnotationView *)annotationView;
        _mapView.userLocationAnnotationView.canShowCallout = NO;
    }
    else if ([annotation isKindOfClass:[TSAgencyAnnotation class]]) {

        annotationView = (TSOrganizationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSAgencyAnnotation class])];
        if (!annotationView) {
            annotationView = [[TSOrganizationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSAgencyAnnotation class])];
        }
        ((TSOrganizationAnnotationView *)annotationView).image = ((TSAgencyAnnotation *)annotation).image;
    }
    else if ([annotation isKindOfClass:[TSSelectedDestinationAnnotation class]]) {
        annotationView = (TSDestinationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSSelectedDestinationAnnotation class])];
        [annotationView displayTransportationType:annotation];
        if (!annotationView) {
            annotationView = [[TSDestinationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSSelectedDestinationAnnotation class])];
        }
    }
    else if ([annotation isKindOfClass:[TSRouteTimeAnnotation class]]) {
        
        annotationView = (TSRouteTimeAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSRouteTimeAnnotation class])];
        if (!annotationView) {
            annotationView = [[TSRouteTimeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSRouteTimeAnnotation class])];
        }
        [annotationView setupViewForAnnotation:annotation];
    }
    else if ([annotation isKindOfClass:[TSSpotCrimeAnnotation class]]) {
        
        NSString *reuseIdentifier = NSStringFromClass([TSSpotCrimeAnnotation class]);//[NSString stringWithFormat:@"%@-%@", [(TSSpotCrimeAnnotation *)annotation spotCrime].type, [TSJavelinAPISocialCrimeReport socialReportTypesToString:[(TSSpotCrimeAnnotation *)annotation socialReport].reportType]];
        
        annotationView = (TSSpotCrimeAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        
        if (!annotationView) {
            annotationView = [[TSSpotCrimeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
    }
    else if ([annotation isKindOfClass:[ADClusterAnnotation class]]) {
        
        ADClusterAnnotation *clusterAnnotation = (ADClusterAnnotation *)annotation;
        TSSpotCrimeAnnotation *spotCrimeAnnotation;
        if (clusterAnnotation.cluster) {
            spotCrimeAnnotation = [clusterAnnotation.originalAnnotations firstObject];
        }
        
        NSString *reuseIdentifier = [NSString stringWithFormat:@"%@-%@", [spotCrimeAnnotation spotCrime].type, [TSJavelinAPISocialCrimeReport socialReportTypesToString:[spotCrimeAnnotation socialReport].reportType]];
        
        annotationView = (TSSpotCrimeAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        [annotationView setAnnotation:annotation];
        
        if (!annotationView) {
            annotationView = [[TSSpotCrimeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        
        ((TSSpotCrimeAnnotationView *)annotationView).alpha = [annotationView alphaForReportDate];
    }
    else {
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"errorAnnotationView"];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"errorAnnotationView"];
            ((MKPinAnnotationView *)annotationView).canShowCallout = NO;
            ((MKPinAnnotationView *)annotationView).pinColor = MKPinAnnotationColorRed;
        }
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
    [self flipIntersectingRouteAnnotation];
    
    
    
    CGRect visibleRect = [mapView annotationVisibleRect];
    for (TSBaseAnnotationView *view in views) {
        
        if ([view isKindOfClass:[TSBaseAnnotationView class]]) {
            
            if (![view.annotation isKindOfClass:[TSBaseMapAnnotation class]] ||
                [view isKindOfClass:[TSUserAnnotationView class]]) {
                return;
            }
            
            if (((TSBaseMapAnnotation *)view.annotation).firstAdd) {
                ((TSBaseMapAnnotation *)view.annotation).firstAdd = NO;
                
                if (!_viewDidAppear) {
                    return;
                }
                CGRect endFrame = view.frame;
                
                CGRect startFrame = endFrame; startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
                view.frame = startFrame;
                
                [UIView beginAnimations:@"drop" context:NULL];
                [UIView setAnimationDuration:0.3];
                
                view.frame = endFrame;
                
                [UIView commitAnimations];
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = YES;
    
    [_mapView removeAnimatedOverlay];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = NO;
    
    if (_viewDidAppear) {
        [_mapView resetAnimatedOverlayAt:[TSLocationController sharedLocationController].location];
    }
    
    CLLocation *location = [TSLocationController sharedLocationController].location;
    if (_isTrackingUser) {
        //avoid loop from negligible differences in region change during zoom
        if (fabs(_mapView.region.center.latitude - location.coordinate.latitude) >= .0000001 ||
            fabs(_mapView.region.center.longitude - location.coordinate.longitude) >= .0000001) {
            [_mapView setCenterCoordinate:location.coordinate animated:_viewDidAppear];
        }
    }
    else {
        CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:[mapView centerCoordinate].latitude
                                                                longitude:[mapView centerCoordinate].longitude];
        [_reportManager getReportsForMapCenter:centerLocation];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view isKindOfClass:[TSUserAnnotationView class]]) {
        _mapView.shouldUpdateCallOut = YES;
        
        [self geocoderUpdateUserLocationAnnotationCallOutForLocation:[TSLocationController sharedLocationController].location];
    }
    
    
    MKCoordinateSpan span = mapView.region.span;
    
    if ([view isKindOfClass:[TSSpotCrimeAnnotationView class]]) {
        view.alpha = 1.0;
        
        NSString *subtitle;
        
        TSSpotCrimeAnnotation *annotation;
        
        if ([view.annotation isKindOfClass:[ADClusterAnnotation class]]) {
            if (((ADClusterAnnotation *)view.annotation).cluster) {
                annotation = [((ADClusterAnnotation *)view.annotation).originalAnnotations firstObject];
            }
        }
        else {
            annotation = (TSSpotCrimeAnnotation *)view.annotation;
        }
        
        TSSpotCrimeLocation *location = annotation.spotCrime;
        TSJavelinAPISocialCrimeReport *report = annotation.socialReport;
        
        if (report) {
            subtitle = [TSUtilities dateDescriptionSinceNow:report.creationDate];
        }
        else {
            subtitle = [TSUtilities dateDescriptionSinceNow:location.date];
        }
        
        annotation.subtitle = subtitle;
        ((ADClusterAnnotation *)view.annotation).subtitle = subtitle;
        ((ADClusterAnnotation *)view.annotation).title = annotation.title;
        
        if (span.longitudeDelta > kMaxLonDeltaCluster) {
            
            [self moveMapView:mapView coordinate:view.annotation.coordinate spanDelta:kMaxLonDeltaCluster];
        }
    }
    
    if ([view isKindOfClass:[TSRouteTimeAnnotationView class]]) {
        [[TSVirtualEntourageManager sharedManager].routeManager selectedRouteAnnotationView:(TSRouteTimeAnnotationView *)view];
        [self flipIntersectingRouteAnnotation];
    }
    
    if ([view isKindOfClass:[TSClusterAnnotationView class]]){
        
        float delta;
        
        if (span.longitudeDelta > .4) {
            delta = span.longitudeDelta*.3;
        }
//        else if (span.longitudeDelta > kMaxLonDeltaCluster) {
//            delta = kMaxLonDeltaCluster;
//        }
        else {
            delta = span.longitudeDelta*.5;
        }
        
        [self moveMapView:mapView coordinate:view.annotation.coordinate spanDelta:delta];
    }
    
    [_mapView bringSubviewToFront:view];
}

- (void)moveMapView:(MKMapView *)mapView coordinate:(CLLocationCoordinate2D)coordinate spanDelta:(float)delta {
    
    [self setIsTrackingUser:NO animateToUser:NO];
    
    MKCoordinateRegion region = mapView.region;
    MKCoordinateSpan span = mapView.region.span;
    
    span.latitudeDelta = delta;
    span.longitudeDelta = delta;
    
    region.span = span;
    region.center = coordinate;
    [mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    if ([view isKindOfClass:[TSUserAnnotationView class]]) {
        _mapView.shouldUpdateCallOut = NO;
    }
    
    if ([view isKindOfClass:[TSSpotCrimeAnnotationView class]]) {
        view.alpha = [(TSSpotCrimeAnnotationView *)view alphaForReportDate];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    
    if ([view isKindOfClass:[TSSpotCrimeAnnotationView class]]) {
        
        id<MKAnnotation> annotation;
        if ([view.annotation isKindOfClass:[ADClusterAnnotation class]]) {
            if (((ADClusterAnnotation *)view.annotation).cluster) {
                annotation = [((ADClusterAnnotation *)view.annotation).originalAnnotations firstObject];
            }
        }
        else {
            annotation = view.annotation;
        }
        
        TSViewReportDetailsViewController *controller = [TSViewReportDetailsViewController presentDetails:(TSSpotCrimeAnnotation *)annotation
                                                                                                     from:self];
        controller.reportManager = _reportManager;
    }
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    
//    if (_firstMapLoad) {
//        _firstMapLoad = NO;
//        [_mapView setRegionAtAppearanceAnimated:YES];
//    }
    NSLog(@"Failed Loading Map");
}
//- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
//    
//    if (_firstMapLoad) {
//        _firstMapLoad = NO;
//        [_mapView setRegionAtAppearanceAnimated:YES];
//    }
//}


- (void)flipIntersectingRouteAnnotation {
    
    NSMutableArray *annotationViewArray = [[NSMutableArray alloc] initWithCapacity:5];
    for (UIView *view in [_mapView.subviews copy]) {
        for (UIView *subview in [view.subviews copy]) {
            if ([subview isKindOfClass:NSClassFromString(@"MKNewAnnotationContainerView")]) {
                for (UIView *annotationView in [subview.subviews copy]) {
                    if ([annotationView isKindOfClass:[TSRouteTimeAnnotationView class]]) {
                        [annotationViewArray addObject:annotationView];
                        if ([((TSRouteTimeAnnotationView *)annotationView).annotation isEqual:[TSVirtualEntourageManager sharedManager].routeManager.selectedRoute.routeTimeAnnotation]) {
                            [subview bringSubviewToFront:annotationView];
                        }
                    }
                }
            }
        }
    }
    for (TSRouteTimeAnnotationView *routeView in annotationViewArray) {
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:annotationViewArray];
        [mutableArray removeObject:routeView];
        
        for (TSRouteTimeAnnotationView *otherView in mutableArray) {
            if(CGRectIntersectsRect([routeView frame], [otherView frame])) {
                NSLog(@"Need To Flip.");
                [routeView flipViewAwayfromView:otherView];
            }
        }
    }
}

#pragma mark - ADClusterMapViewDelegate

- (MKAnnotationView *)mapView:(ADClusterMapView *)mapView viewForClusterAnnotation:(id<MKAnnotation>)annotation {
    TSClusterAnnotationView * pinView = (TSClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ADMapCluster"];
    if (!pinView) {
        pinView = [[TSClusterAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:@"ADMapCluster"];
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}


- (void)mapViewDidFinishClustering:(ADClusterMapView *)mapView {
    NSLog(@"Done");
}

- (NSUInteger)numberOfClustersInMapView:(ADClusterMapView *)mapView {
    
    return 25;
}

- (double)clusterDiscriminationPowerForMapView:(ADClusterMapView *)mapView {
    return 1.8;
}


#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    textField.backgroundColor = [TSColorPalette whiteColor];
    
    if ([textField.text length] + [string length] - range.length == 4) {
        textField.text = [textField.text stringByAppendingString:string];
        [self checkDisarmCode:textField];
        return NO;
    }
    else if ([textField.text length] + [string length] - range.length > 4) {
        [self checkDisarmCode:textField];
        return NO;
    }
    
    return YES;
}

- (void)checkDisarmCode:(UITextField *)textField {
    
    if (textField.text.length != 4) {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
        return;
    }
    
    if ([textField.text isEqualToString:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode]) {
        [[TSVirtualEntourageManager sharedManager] manuallyEndTracking];
        [_cancelEntourageAlertController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
    }
}




#pragma mark - Touch ID

- (void)useTouchID {
    
    LAContext *context = [[LAContext alloc] init];
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:@"Stop Entourage"
                      reply:^(BOOL success, NSError *error) {
                          
                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                              if (error) {
                                  
                                  if (error.code == kLAErrorUserCancel ||
                                      error.code == kLAErrorSystemCancel) {
                                      
                                  }
                                  else if (error.code == kLAErrorUserFallback) {
                                      [self enterPasscodeCancel];
                                  }
                                  else {
                                      UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                                      [errorController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                                      [self presentViewController:errorController animated:YES completion:nil];
                                  }
                              }
                              else if (success) {
                                  [[TSVirtualEntourageManager sharedManager] manuallyEndTracking];
                              }
                          }];
                      }];
}

- (BOOL)touchIDAvailable {
    
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}


#pragma mark - Alert Buttons

- (IBAction)callEmergencyNumber:(id)sender {
    [self hideCallChatButtons];
    
}

- (IBAction)callAgencyDispatcher:(id)sender {
    [self hideCallChatButtons];
    
}

- (IBAction)openChat:(id)sender {
    
    [self hideCallChatButtons];
    
    if (![TSLocationController sharedLocationController].geofence.currentAgency) {
        [[TSLocationController sharedLocationController].geofence showOutsideBoundariesWindow];
        return;
    }
    
    [[TSAlertManager sharedManager] showAlertWindowForChatWithCurrentHomeView:self];
    [self showOnlyMap];
}

- (void)initCallChatButtons {
    
    CGRect frame = _routeButton.frame;
//    frame.size.height += 10;
//    frame.size.width = frame.size.height;
    
    _policeButton = [[TSBottomMapButton alloc] initWithFrame:frame];
    [_policeButton setImage:[UIImage imageNamed:@"phone_call"] forState:UIControlStateNormal];
    [_policeButton setLabelTitle:@"Police"];
    [_policeButton addTarget:self action:@selector(callAgencyDispatcher:) forControlEvents:UIControlEventTouchUpInside];
    
    _emergencyButton = [[TSBottomMapButton alloc] initWithFrame:frame];
    [_emergencyButton setImage:[UIImage imageNamed:@"call_911"] forState:UIControlStateNormal];
    [_emergencyButton setLabelTitle:@"Call"];
    [_emergencyButton addTarget:self action:@selector(callEmergencyNumber:) forControlEvents:UIControlEventTouchUpInside];
    
    _chatButton = [[TSBottomMapButton alloc] initWithFrame:frame];
    [_chatButton setImage:[UIImage imageNamed:@"alert_chat_icon"] forState:UIControlStateNormal];
    [_chatButton setLabelTitle:@"Chat"];
    [_chatButton addTarget:self action:@selector(openChat:) forControlEvents:UIControlEventTouchUpInside];
    
    float scale = 1.5;
    
    _policeButton.transform = CGAffineTransformMakeScale(scale, scale);
    _emergencyButton.transform = CGAffineTransformMakeScale(scale, scale);
    _chatButton.transform = CGAffineTransformMakeScale(scale, scale);
    
    _policeButton.center = _helpButton.superview.center;
    _emergencyButton.center = _helpButton.superview.center;
    _chatButton.center = _helpButton.superview.center;
    
    [self.view insertSubview:_policeButton belowSubview:_helpButton.superview];
    [self.view insertSubview:_emergencyButton belowSubview:_helpButton.superview];
    [self.view insertSubview:_chatButton belowSubview:_helpButton.superview];
    
    _policeButton.hidden = YES;
    _emergencyButton.hidden = YES;
    _chatButton.hidden = YES;
}

- (void)showCallChatButtons {
    
    [_policeButton.layer removeAllAnimations];
    [_emergencyButton.layer removeAllAnimations];
    [_chatButton.layer removeAllAnimations];
    [_reportButton.layer removeAllAnimations];
    [_routeButton.layer removeAllAnimations];
    
    _policeButton.hidden = NO;
    _emergencyButton.hidden = NO;
    _chatButton.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        _policeButton.transform = CGAffineTransformIdentity;
        _emergencyButton.transform = CGAffineTransformIdentity;
        _chatButton.transform = CGAffineTransformIdentity;
        
        _policeButton.center = [self pointOnCircleWithView:_helpButton.superview radius:_helpButton.frame.size.height*1.1 angle:215];
        _emergencyButton.center = [self pointOnCircleWithView:_helpButton.superview radius:_helpButton.frame.size.height*1.1 angle:270];
        _chatButton.center = [self pointOnCircleWithView:_helpButton.superview radius:_helpButton.frame.size.height*1.1 angle:325];
        
        _reportButton.transform = CGAffineTransformMakeScale(0.001, 0.001);
        _routeButton.transform = CGAffineTransformMakeScale(0.001, 0.001);
        
        _helpButton.label.hidden = YES;
        _helpButton.transform = CGAffineTransformMakeScale(0.6667, 0.6667);
        
    } completion:nil];
}

- (CGPoint)pointOnCircleWithView:(UIView *)view radius:(float)radius angle:(float)angle {
    CGPoint newPoint;
    newPoint.x = view.center.x + (radius * cosf(angle * M_PI / 180));
    newPoint.y = view.center.y + (radius * sinf(angle * M_PI / 180));
    
    return newPoint;
}


- (void)hideCallChatButtons {
    
    [_policeButton.layer removeAllAnimations];
    [_emergencyButton.layer removeAllAnimations];
    [_chatButton.layer removeAllAnimations];
    [_reportButton.layer removeAllAnimations];
    [_routeButton.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        float scale = 1.5;
        
        _policeButton.transform = CGAffineTransformMakeScale(scale, scale);
        _emergencyButton.transform = CGAffineTransformMakeScale(scale, scale);
        _chatButton.transform = CGAffineTransformMakeScale(scale, scale);
        
        _policeButton.center = _helpButton.superview.center;
        _emergencyButton.center = _helpButton.superview.center;
        _chatButton.center = _helpButton.superview.center;
        
        _reportButton.transform = CGAffineTransformIdentity;
        _routeButton.transform = CGAffineTransformIdentity;
        _helpButton.transform = CGAffineTransformIdentity;
        
        _helpButton.label.hidden = NO;
        
    } completion:^(BOOL finished) {
        if (finished && _policeButton.transform.a != CGAffineTransformIdentity.a) {
            _policeButton.hidden = YES;
            _emergencyButton.hidden = YES;
            _chatButton.hidden = YES;
        }
    }];
}


@end
