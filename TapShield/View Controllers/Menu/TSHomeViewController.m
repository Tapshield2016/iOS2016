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

static NSString * const kYankHintOff = @"To activate yank, select button and insert headphones.  When headphones are yanked from the headphone jack, you will have 10 seconds to disarm before an alert is sent";
static NSString * const kYankHintOn = @"To disable yank, select button, and when notified, you may remove your headphones";


@interface TSHomeViewController ()

@property (nonatomic, strong) TSTopDownTransitioningDelegate *topDownTransitioningDelegate;
@property (nonatomic, strong) TSBottomUpTransitioningDelegate *bottomUpTransitioningDelegate;
@property (nonatomic, strong) TSTransformCenterTransitioningDelegate *transformCenterTransitioningDelegate;
@property (strong, nonatomic) FBKVOController *kvoController;
@property (nonatomic) BOOL viewDidAppear;
@property (strong, nonatomic) UIAlertView *cancelEntourageAlertView;
@property (strong, nonatomic) TSBaseLabel *timerLabel;
@property (assign, nonatomic) BOOL annotationsLoaded;
@property (assign, nonatomic) BOOL firstMapLoad;

@end

@implementation TSHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _firstMapLoad = YES;
    _isTrackingUser = YES;
    _statusView.hidden = YES;
    
    _annotationsLoaded = NO;
    
    self.showSmallLogoInNavBar = YES;
    _mapView.isAnimatingToRegion = YES;
    
    _reportManager = [[TSReportAnnotationManager alloc] initWithMapView:_mapView];
    
    [TSVirtualEntourageManager initSharedEntourageManagerWithHomeView:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Yank_icon"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(toggleYank:)];
    self.navigationItem.rightBarButtonItem.accessibilityLabel = @"Yank";
    self.navigationItem.rightBarButtonItem.accessibilityValue = @"Off";
    self.navigationItem.rightBarButtonItem.accessibilityHint = kYankHintOff;

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
                                             selector:@selector(sendAlert:)
                                                 name:TSVirtualEntourageManagerTimerDidEnd
                                               object:nil];
    
    _statusViewHeight.constant = 0;
    
    [[TSLocationController sharedLocationController] bestAccuracyRefresh];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    _mapView.isAnimatingToRegion = YES;
    [_mapView removeAnimatedOverlay];
    
    if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser]) {
        [self addOverlaysAndAnnotations];
    }
    
    if ([TSYankManager sharedYankManager].isEnabled) {
        [self.navigationItem.rightBarButtonItem setImage:[[UIImage imageNamed:@"Yank_icon_red"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        self.navigationItem.rightBarButtonItem.accessibilityValue = @"On";
        self.navigationItem.rightBarButtonItem.accessibilityHint = kYankHintOn;
    }
    else {
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"Yank_icon"]];
        self.navigationItem.rightBarButtonItem.accessibilityValue = @"Off";
        self.navigationItem.rightBarButtonItem.accessibilityHint = kYankHintOff;
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
    
    if (_shouldSendAlert) {
        [self sendYankAlert];
    }
    
    if (_firstMapLoad) {
        _firstMapLoad = NO;
        [_mapView setRegionAtAppearanceAnimated:YES];
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

- (void)didMoveToParentViewController:(UIViewController *)parent {
    
    [super willMoveToParentViewController:parent];
    
    if (!parent) {
        [TSLocationController sharedLocationController].delegate = nil;
        [[TSVirtualEntourageManager sharedManager] removeHomeViewController];
        _mapView.mapType = MKMapTypeStandard;
        [_mapView removeFromSuperview];
        _mapView = nil;
    }
}

- (void)dealloc {
    
    [TSLocationController sharedLocationController].delegate = nil;
    [[TSVirtualEntourageManager sharedManager] removeHomeViewController];
    _mapView.mapType = MKMapTypeStandard;
    [_mapView removeFromSuperview];
    _mapView = nil;
    
}

#pragma mark - Map Setup

- (void)addOverlaysAndAnnotations {
    
    [TSLocationController sharedLocationController].delegate = self;
    if (!_annotationsLoaded) {
        
        [_mapView refreshRegionBoundariesOverlay];
        
        [[TSLocationController sharedLocationController] startStandardLocationUpdates:^(CLLocation *location) {
            
            _annotationsLoaded = YES;
            [[TSLocationController sharedLocationController].geofence updateNearbyAgencies];
            [_reportManager performSelector:@selector(loadSpotCrimeAndSocialAnnotations:) withObject:location afterDelay:2.0];
            [self addUserLocationAnnotation:location];
            [self geocoderUpdateUserLocationAnnotationCallOutForLocation:location];
        }];
    }
}

- (void)addUserLocationAnnotation:(CLLocation *)location {
    
    if (!_mapView.userLocationAnnotation) {
        
        _kvoController = [FBKVOController controllerWithObserver:self];
        [_kvoController observe:[TSJavelinAPIClient loggedInUser].userProfile
                        keyPath:@"profileImage"
                        options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(TSUserAnnotationView *view, TSJavelinAPIUserProfile *userProfile, NSDictionary *change) {
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                
                                [_mapView removeAnnotation:_mapView.userLocationAnnotation];
                                
                                _mapView.userLocationAnnotation = [[TSUserLocationAnnotation alloc] initWithCoordinates:location.coordinate
                                                                                                              placeName:nil
                                                                                                            description:nil];
                                
                                [_mapView addAnnotation:_mapView.userLocationAnnotation];
                                [_mapView updateAccuracyCircleWithLocation:location];
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
    self.isTrackingUser = YES;
    [self drawerCanDragForMenu:NO];
    [self adjustViewableTime];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"End Tracking" style:UIBarButtonItemStylePlain target:self action:@selector(cancelEntourage)];
    [barButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue],
                                        NSFontAttributeName :[TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f]} forState:UIControlStateNormal];
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
    
    _cancelEntourageAlertView = [[UIAlertView alloc] initWithTitle:@"Stop Entourage"
                                                       message:@"Please enter passcode"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:nil];
    _cancelEntourageAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [_cancelEntourageAlertView textFieldAtIndex:0];
    [textField setPlaceholder:@"1234"];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setSecureTextEntry:YES];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [textField setDelegate:self];
    
    [_cancelEntourageAlertView show];
}

- (void)toggleYank:(id)sender {
    
    [[TSYankManager sharedYankManager] enableYank:^(BOOL enabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (enabled) {
                [self.navigationItem.rightBarButtonItem setImage:[[UIImage imageNamed:@"Yank_icon_red"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                self.navigationItem.rightBarButtonItem.accessibilityValue = @"On";
                self.navigationItem.rightBarButtonItem.accessibilityHint = kYankHintOn;
            }
            else {
                [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"Yank_icon"]];
                self.navigationItem.rightBarButtonItem.accessibilityValue = @"Off";
                self.navigationItem.rightBarButtonItem.accessibilityHint = kYankHintOff;
            }
        });
    }];
}

- (void)sendYankAlert {
    
    [self performSelectorOnMainThread:@selector(sendAlert:) withObject:@"T" waitUntilDone:NO];
}

- (IBAction)sendAlert:(id)sender {
    
    _shouldSendAlert = NO;
    _mapView.shouldUpdateCallOut = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.presentedViewController) {
            if ([self.presentedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController *)self.presentedViewController;
                UIViewController *viewController = nav.topViewController;
                //already presented
                if ([viewController isKindOfClass:[TSPageViewController class]]) {
                    return;
                }
                //dismiss any view presented first
                else {
                    
                    [viewController dismissViewControllerAnimated:YES completion:^{
                        [self performSelector:@selector(sendAlert:) withObject:sender];
                    }];
                    return;
                }
            }
        }
        
        NSString *type;
        if ([sender isKindOfClass:[NSNotification class]]) {
            type = [(NSNotification *)sender object];
        }
        else if ([sender isKindOfClass:[NSString class]]) {
            if (((NSString *)sender).length == 1) {
                type = sender;
            }
        }
        
        _transformCenterTransitioningDelegate = [[TSTransformCenterTransitioningDelegate alloc] init];
        
        [[TSAlertManager sharedManager] startAlertCountdown:10 type:type];
        
        TSPageViewController *pageview = (TSPageViewController *)[self presentViewControllerWithClass:[TSPageViewController class] transitionDelegate:_transformCenterTransitioningDelegate animated:YES];
        pageview.homeViewController = self;
        
        [self showOnlyMap];
        [_reportManager hideSpotCrimes];
    });
}

- (IBAction)openChatWindow:(id)sender {
    
    if (![TSLocationController sharedLocationController].geofence.currentAgency) {
        [[TSLocationController sharedLocationController].geofence showOutsideBoundariesWindow];
        return;
    }
    
    if (!_bottomUpTransitioningDelegate) {
        _bottomUpTransitioningDelegate = [[TSBottomUpTransitioningDelegate alloc] init];
    }
    
    TSPageViewController *pageview = (TSPageViewController *)[self presentViewControllerWithClass:[TSPageViewController class] transitionDelegate:_bottomUpTransitioningDelegate animated:YES];
    pageview.homeViewController = self;
    pageview.isChatPresentation = YES;
    
    [self showOnlyMap];
}

- (IBAction)reportAlert:(id)sender {
    
    TSAlertDetailsTableViewController *viewController = (TSAlertDetailsTableViewController *)[self presentViewControllerWithClass:[TSAlertDetailsTableViewController class] transitionDelegate:nil animated:YES];
    
    viewController.reportManager = _reportManager;
}

- (IBAction)displayVirtualEntourage:(id)sender {
    
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

- (IBAction)userLocationTUI:(id)sender {
    
    self.isTrackingUser = YES;
    
    [[TSLocationController sharedLocationController] bestAccuracyRefresh];
}

- (void)setIsTrackingUser:(BOOL)isTrackingUser {
    
    _isTrackingUser = isTrackingUser;
    
    if (isTrackingUser) {
        if (_mapView.region.span.latitudeDelta > 0.1f) {
            [_mapView setRegionAtAppearanceAnimated:YES];
        }
        else {
            [_mapView setCenterCoordinate:[TSLocationController sharedLocationController].location.coordinate animated:_viewDidAppear];
        }
    }
    
    [self geocoderUpdateUserLocationAnnotationCallOutForLocation:[TSLocationController sharedLocationController].location];
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
    
    _statusView.hidden = NO;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _statusViewHeight.constant = height;
                         
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         if (!height) {
                             _statusView.hidden = YES;
                         }
                     }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Gesture handlers

- (void)userDidPanMapView:(ADClusterMapView *)mapView {
    
}

- (void)userWillPanMapView:(ADClusterMapView *)mapView {
    
    _isTrackingUser = NO;
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
    
    _isTrackingUser = NO;
    
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


#pragma mark - Alert View Delegate 


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == _cancelEntourageAlertView) {
        if (buttonIndex == 1) {
            [[TSVirtualEntourageManager sharedManager] manuallyEndTracking];
        }
    }
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
        [_cancelEntourageAlertView dismissWithClickedButtonIndex:1 animated:YES];
    }
    else {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
    }
}


@end
