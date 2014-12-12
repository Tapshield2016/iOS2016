//
//  TSHomeViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHomeViewController.h"
#import "TSRoutePickerViewController.h"
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
#import "TSJavelinChatManager.h"
#import "TSTalkOptionViewController.h"
#import "MBXMapKit.h"
#import "TSEntourageMemberAnnotationView.h"
#import "TSStartAnnotationView.h"
#import "TSStartAnnotation.h"
#import "TSAlertAnnotation.h"
#import "TSAlertAnnotationView.h"

static NSString * const kYankHintOff = @"To activate yank, select button and insert headphones.  When headphones are yanked from the headphone jack, you will have 10 seconds to disarm before an alert is sent";
static NSString * const kYankHintOn = @"To disable yank, select button, and when notified, you may remove your headphones";


@interface TSHomeViewController ()

@property (strong, nonatomic) MBXRasterTileOverlay *rasterOverlay;
@property (strong, nonatomic) TSTalkOptionViewController *talkOptionsViewController;

@property (nonatomic, strong) TSTopDownTransitioningDelegate *topDownTransitioningDelegate;
@property (nonatomic, strong) TSBottomUpTransitioningDelegate *bottomUpTransitioningDelegate;
@property (nonatomic, strong) TSTransformCenterTransitioningDelegate *transformCenterTransitioningDelegate;
@property (strong, nonatomic) FBKVOController *mapKVOController;
@property (strong, nonatomic) FBKVOController *notificationCountKVOController;
@property (nonatomic) BOOL viewDidAppear;

@property (assign, nonatomic) BOOL annotationsLoaded;
@property (assign, nonatomic) BOOL firstMapLoad;
@property (assign, nonatomic) BOOL locationServicesWereDisabled;
@property (strong, nonatomic) UIAlertController *cancelEntourageAlertController;

@property (strong, nonatomic) UIVisualEffectView *blackoutView;

@property (strong, nonatomic) TSIconBadgeView *entourageButtonBadge;

@end

@implementation TSHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _firstMapLoad = YES;
    [self setIsTrackingUser:YES animateToUser:NO];
    _statusView.hidden = YES;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    _annotationsLoaded = NO;
    
    self.showLogoInNavBar = YES;
    _mapView.isAnimatingToRegion = YES;
    
    [TSAlertManager sharedManager].homeViewController = self;
    
    [TSReportAnnotationManager sharedManager].mapView = _mapView;
    
    [TSEntourageSessionManager initSharedEntourageManagerWithHomeView:self];

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
                                                 name:TSJavelinAlertManagerDidReceiveActiveAlertNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendYankAlert)
                                                 name:TSYankManagerDidYankHeadphonesNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendEntourageAlert)
                                                 name:TSEntourageSessionManagerTimerDidEnd
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLeaveAgency:)
                                                 name:TSGeofenceUserDidLeaveAgency
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidEnterAgency:)
                                                 name:TSGeofenceUserDidEnterAgency
                                               object:nil];
    
    _statusViewHeight.constant = 0;
    
    [[TSLocationController sharedLocationController] bestAccuracyRefresh];
    
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
    [_helpButton setLabelTitle:@"Talk"];
    
    _badgeView = [[TSIconBadgeView alloc] initWithFrame:CGRectZero];
    [_helpButton.superview addSubview:_badgeView];
    
    [self initTalkOptionController];
    
    [self monitorNewEntourageNotificationsCount];
//    [self initMapBoxOverlays];
    
    [[TSEntourageSessionManager sharedManager] resumePreviousEntourage];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    _mapView.isAnimatingToRegion = YES;
    [_mapView removeAnimatedOverlay];
    
    if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser]) {
        [self addOverlaysAndAnnotations];
    }
    
    if (_firstMapLoad && !self.firstAppear) {
        _firstMapLoad = NO;
        [_mapView setRegionAtAppearanceAnimated:self.firstAppear];
    }
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if ([TSJavelinAPIClient loggedInUser]) {
        [self whiteNavigationBar];
    }
    
    [[TSReportAnnotationManager sharedManager] showSpotCrimes];
    
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
    
    if (_firstMapLoad && self.firstAppear) {
        _firstMapLoad = NO;
        [_mapView setRegionAtAppearanceAnimated:self.firstAppear];
    }
    
    if ([TSAlertManager sharedManager].isPresented) {
        [self transitionForAlert];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self setStatusViewText:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    [[TSReportAnnotationManager sharedManager] removeOldSpotCrimes];
}

- (void)monitorNewEntourageNotificationsCount {
    
    float size = 34;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-size - 13, 2, size, size)];
    [view setUserInteractionEnabled:NO];
    view.backgroundColor = [UIColor clearColor];
    _entourageButtonBadge = [[TSIconBadgeView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 10, 24, 24) observing:[TSJavelinPushNotificationManager sharedManager] integerKeyPath:@"notificationsNewCount"];
    [view addSubview:_entourageButtonBadge];
    [self.navigationController.navigationBar addSubview:view];
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
            [[TSReportAnnotationManager sharedManager] performSelector:@selector(loadSpotCrimeAndSocialAnnotations:) withObject:location afterDelay:2.0];
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
        _mapKVOController = KVOController;
        
        [_mapKVOController observe:[TSJavelinAPIClient loggedInUser].userProfile
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



#pragma mark - UI Changes

- (void)mapAlertModeToggle {
    
    [_mapView updateAccuracyCircleWithLocation:[TSLocationController sharedLocationController].location];
    [_mapView resetAnimatedOverlayAt:[TSLocationController sharedLocationController].location];
}

- (void)entourageModeOn {
    
    [[TSReportAnnotationManager sharedManager] showSpotCrimes];
    [self setIsTrackingUser:YES animateToUser:YES];
    [self drawerCanDragForMenu:NO];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStylePlain target:self action:@selector(cancelEntourage)];
    [barButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue],
                                        NSFontAttributeName :[TSFont fontWithName:kFontWeightLight size:17.0f]} forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:barButton animated:YES];
}

- (void)clearEntourageMap {
    
    [[TSReportAnnotationManager sharedManager] showSpotCrimes];
    [_menuViewController showMenuButton:self];
    [self drawerCanDragForMenu:YES];
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
    
    _cancelEntourageAlertController = [UIAlertController alertControllerWithTitle:@"Stop Tracking"
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


- (void)sendYankAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_yankButton setTintColor:[TSColorPalette blueButtonColor]];
        _yankButton.layer.borderColor = [TSColorPalette tapshieldBlue].CGColor;
        _yankButton.accessibilityValue = @"Off";
        _yankButton.accessibilityHint = kYankHintOff;
        
        if (![TSAlertManager sharedManager].shouldStartCountdown) {
            return;
        }
        
        [self transitionForAlert];
        [[TSAlertManager sharedManager] startYankAlertCountdown];
    }];
}

- (void)sendEntourageAlert {
    
    if (![TSAlertManager sharedManager].shouldStartCountdown) {
        return;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        [self transitionForAlert];
        [[TSAlertManager sharedManager] startEntourageAlertCountdown];
        
    }];
}

- (IBAction)sendAlert:(id)sender {
    
    
    
    _helpButton.selected = !_helpButton.selected;
    
    if (_helpButton.selected) {
        if ([TSJavelinChatManager sharedManager].unreadMessages != 0) {
            [self openChat:nil];
            return;
        }
        [_badgeView removeFromSuperview];
        [self showCallChatButtons];
    }
    else {
        [self hideCallChatButtons];
    }
}

- (void)transitionForAlert {
    
    _mapView.shouldUpdateCallOut = YES;
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self showOnlyMap];
    [[TSReportAnnotationManager sharedManager] hideSpotCrimes];
}

- (IBAction)openEntourage:(id)sender {
    
    [[TSReportAnnotationManager sharedManager] hideSpotCrimes];
    [[TSEntourageSessionManager sharedManager] stopStatusBartTimer];
    
    if (!_topDownTransitioningDelegate) {
        _topDownTransitioningDelegate = [[TSTopDownTransitioningDelegate alloc] init];
    }
    
    if (![TSEntourageSessionManager sharedManager].isEnabled) {
        TSRoutePickerViewController *viewController = (TSRoutePickerViewController *)[self presentViewControllerWithClass:[TSRoutePickerViewController class] transitionDelegate:_topDownTransitioningDelegate animated:YES];
        viewController.homeViewController = self;
        
        [self showOnlyMap];
    }
    else {
        
        TSNotifySelectionViewController *viewController = (TSNotifySelectionViewController *)[self presentViewControllerWithClass:[TSNotifySelectionViewController class] transitionDelegate:_topDownTransitioningDelegate animated:YES];
        viewController.homeViewController = self;
    }
}

- (IBAction)reportAlert:(id)sender {
    
    [self presentViewControllerWithClass:[TSAlertDetailsTableViewController class] transitionDelegate:nil animated:YES];
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
    
    if (_isTrackingUser) {
        [_mapView setRegionAtAppearanceAnimated:YES];
    }
    
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
    
    if (!self.viewDidAppear) {
        [self performSelector:@selector(setStatusViewText:) withObject:string afterDelay:1.0];
        return;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_statusView setText:string];
    }];
    
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
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
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
    
    [self setIsTrackingUser:NO animateToUser:NO];
    [self setStatusViewText:nil];
    [_geocoder cancelGeocode];
}

- (void)handleTap:(UIGestureRecognizer *)recognizer {
    
    if ([TSEntourageSessionManager sharedManager].isEnabled ) {
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
            [[TSEntourageSessionManager sharedManager].routeManager selectRouteClosestTo:mapPoint];
        }
    }
}




#pragma mark - TSLocationControllerDelegate methods

- (void)locationDidUpdate:(CLLocation *)location {
    
    if ([TSEntourageSessionManager sharedManager].isEnabled) {
        [[TSEntourageSessionManager sharedManager] checkRegion:location];
    }
    
    if (_mapView.userLocationAnnotation) {
        [_mapView removeAccuracyCircleOverlay];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [_mapView.userLocationAnnotationView.layer removeAllAnimations];
            [_mapView.animatedOverlay.layer removeAllAnimations];
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                if (_viewDidAppear) {
                    [_mapView resetAnimatedOverlayAt:location];
                }
                _mapView.userLocationAnnotation.coordinate = location.coordinate;
                
            } completion:^(BOOL finished) {
                if (finished) {
                    [_mapView updateAccuracyCircleWithLocation:location];
                }
            }];
        }];
        
        
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
        
        [_geocoder cancelGeocode];
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
                
                _userLocationItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:placemark]];
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
    
    if ([overlay isKindOfClass:[TSEntourageSessionPolyline class]]) {
        return [(TSEntourageSessionPolyline *)overlay renderer];
    }
    else if([overlay isKindOfClass:[MKPolygon class]]){
        
        return [TSMapView mapViewPolygonOverlay:overlay];
    }
    else if ([overlay isKindOfClass:[MKCircle class]] ||
             [overlay isKindOfClass:[TSHeatMapOverlay class]]) {
        
        return [TSMapView mapViewCircleOverlay:overlay];
    }
    else if ([overlay isKindOfClass:[MKPolyline class]]) {
        return [self rendererForRoutePolyline:overlay];
    }
    else if ([overlay isKindOfClass:[MBXRasterTileOverlay class]]) {
        MKTileOverlayRenderer *renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        return renderer;
    }
    
    return nil;
}

- (MKPolylineRenderer *)rendererForRoutePolyline:(id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    [renderer setLineWidth:6.0];
    [renderer setStrokeColor:[TSColorPalette lightGrayColor]];
    
    if (![TSEntourageSessionManager sharedManager].routeManager.routeOptions && [TSEntourageSessionManager sharedManager].routeManager.selectedRoute.polyline == overlay) {
        [renderer setStrokeColor:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.8]];
        return renderer;
    }
    
    if (![TSEntourageSessionManager sharedManager].routeManager.selectedRoute) {
        [TSEntourageSessionManager sharedManager].routeManager.selectedRoute = [[TSEntourageSessionManager sharedManager].routeManager.routeOptions firstObject];
    }
    
    if ([TSEntourageSessionManager sharedManager].routeManager.selectedRoute) {
        for (TSRouteOption *routeOption in [TSEntourageSessionManager sharedManager].routeManager.routeOptions) {
            if (routeOption == [TSEntourageSessionManager sharedManager].routeManager.selectedRoute) {
                if (routeOption.polyline == overlay) {
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
    else if ([annotation isKindOfClass:[TSEntourageMemberAnnotation class]]) {
        annotationView = (TSEntourageMemberAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSEntourageMemberAnnotationView class])];
        if (!annotationView) {
            annotationView = [[TSEntourageMemberAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSEntourageMemberAnnotationView class])];
        }
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
    else if ([annotation isKindOfClass:[TSStartAnnotation class]]) {
        annotationView = (TSStartAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSStartAnnotation class])];
        if (!annotationView) {
            annotationView = [[TSStartAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSStartAnnotation class])];
        }
    }
    else if ([annotation isKindOfClass:[TSAlertAnnotation class]]) {
        annotationView = (TSAlertAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSAlertAnnotation class])];
        if (!annotationView) {
            annotationView = [[TSAlertAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSAlertAnnotation class])];
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
                [view isKindOfClass:[TSUserAnnotationView class]] ||
                [view isKindOfClass:[TSEntourageMemberAnnotationView class]] ||
                [view isKindOfClass:[TSDestinationAnnotationView class]]) {
                return;
            }
            
            if (((TSBaseMapAnnotation *)view.annotation).firstAdd) {
                ((TSBaseMapAnnotation *)view.annotation).firstAdd = NO;
                
                if (!_viewDidAppear) {
                    return;
                }
                
                CGRect endFrame = view.frame;
                
                if ([view isKindOfClass:[TSRouteTimeAnnotationView class]]) {
                    view.transform = CGAffineTransformMakeScale(0.001, 0.001);
                }
                else {
                    CGRect startFrame = endFrame;
                    startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
                    view.frame = startFrame;
                }
                
                [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    if ([view isKindOfClass:[TSRouteTimeAnnotationView class]]) {
                        view.transform = CGAffineTransformIdentity;
                    }
                    else {
                        view.frame = endFrame;
                    }
                } completion:nil];
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
        [[TSReportAnnotationManager sharedManager] getReportsForMapCenter:centerLocation];
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
            subtitle = [report.creationDate dateDescriptionSinceNow];
        }
        else {
            subtitle = [location.date dateDescriptionSinceNow];
        }
        
        annotation.subtitle = subtitle;
        ((ADClusterAnnotation *)view.annotation).subtitle = subtitle;
        ((ADClusterAnnotation *)view.annotation).title = annotation.title;
        
        if (span.longitudeDelta > kMaxLonDeltaCluster) {
            [self moveMapViewToCoordinate:view.annotation.coordinate spanDelta:kMaxLonDeltaCluster];
        }
    }
    
    if ([view isKindOfClass:[TSRouteTimeAnnotationView class]]) {
        [[TSEntourageSessionManager sharedManager].routeManager selectedRouteAnnotationView:(TSRouteTimeAnnotationView *)view];
        [self flipIntersectingRouteAnnotation];
    }
    
    if ([view isKindOfClass:[TSClusterAnnotationView class]]){
        
        float delta;
        
        if (span.longitudeDelta > .4) {
            delta = span.longitudeDelta*.3;
        }
        else {
            delta = span.longitudeDelta*.5;
        }
        
        [self moveMapViewToCoordinate:view.annotation.coordinate spanDelta:delta];
    }
    
    [_mapView bringSubviewToFront:view];
}

- (void)moveMapViewToCoordinate:(CLLocationCoordinate2D)coordinate spanDelta:(float)delta {
    
    [self setIsTrackingUser:NO animateToUser:NO];
    
    MKCoordinateRegion region = _mapView.region;
    MKCoordinateSpan span = _mapView.region.span;
    
    span.latitudeDelta = delta;
    span.longitudeDelta = delta;
    
    region.span = span;
    region.center = coordinate;
    [_mapView setRegion:region animated:YES];
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
        
        [TSViewReportDetailsViewController presentDetails:(TSSpotCrimeAnnotation *)annotation from:self];
    }
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    
    NSLog(@"Failed Loading Map");
}



- (void)flipIntersectingRouteAnnotation {
    
    NSMutableArray *annotationViewArray = [[NSMutableArray alloc] initWithCapacity:5];
    for (UIView *view in [_mapView.subviews copy]) {
        for (UIView *subview in [view.subviews copy]) {
            if ([subview isKindOfClass:NSClassFromString(@"MKNewAnnotationContainerView")]) {
                for (UIView *annotationView in [subview.subviews copy]) {
                    if ([annotationView isKindOfClass:[TSRouteTimeAnnotationView class]]) {
                        [annotationViewArray addObject:annotationView];
                        if ([((TSRouteTimeAnnotationView *)annotationView).annotation isEqual:[TSEntourageSessionManager sharedManager].routeManager.selectedRoute.routeTimeAnnotation]) {
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
        [[TSEntourageSessionManager sharedManager] manuallyEndTracking];
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
            localizedReason:@"Stop Tracking"
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
                                  [[TSEntourageSessionManager sharedManager] manuallyEndTracking];
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
    [self transitionForAlert];
    [[TSAlertManager sharedManager] startEmergencyNumberAlert];
}

- (IBAction)callAgencyDispatcher:(id)sender {
    
    if (![TSAlertManager sharedManager].isAlertInProgress && ![TSJavelinAPIClient loggedInUser].agency) {
        [[TSLocationController sharedLocationController].geofence showOutsideBoundariesWindow];
        return;
    }
    
    [self hideCallChatButtons];
    [self transitionForAlert];
    [[TSAlertManager sharedManager] startAgencyDispathcerCallAlert];
}

- (IBAction)openChat:(id)sender {
    
    if (![TSAlertManager sharedManager].isAlertInProgress && ![TSLocationController sharedLocationController].geofence.currentAgency) {
        [[TSLocationController sharedLocationController].geofence showOutsideBoundariesWindow];
        return;
    }
    
    [self hideCallChatButtons];
    [[TSAlertManager sharedManager] showAlertWindowForChat];
    [self transitionForAlert];
}

- (void)showCallChatButtons {
    
    _helpButton.selected = YES;
    [_talkOptionsViewController showTalkButtons];
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        _helpButton.label.hidden = YES;
        
        CGAffineTransform t = CGAffineTransformMakeScale(0.6667, 0.6667);
        t = CGAffineTransformTranslate(t, 0, 15);
        _helpButton.transform = t;
        
        _blackoutView.hidden = NO;
    } completion:nil];
}


- (void)hideCallChatButtons {
    
    _helpButton.selected = NO;
    [_talkOptionsViewController hideTalkButtons];
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        _helpButton.transform = CGAffineTransformIdentity;
        _blackoutView.hidden = YES;
        _helpButton.label.hidden = NO;
    } completion:^(BOOL finished) {
        if (finished && _helpButton.transform.a == CGAffineTransformIdentity.a) {
            [_helpButton.superview addSubview:_badgeView];
        }
    }];
}

- (void)initTalkOptionController {
    float inset = 30;
    _talkOptionsViewController = [[TSTalkOptionViewController alloc] init];
    CGRect talkOptionFrame = CGRectMake(inset, self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width-inset*2, self.view.frame.size.height - (self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height)*2);
    _talkOptionsViewController.view.frame = talkOptionFrame;
    [_talkOptionsViewController willMoveToParentViewController:self];
    [_talkOptionsViewController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:_talkOptionsViewController];
    [self.view insertSubview:_talkOptionsViewController.view belowSubview:_helpButton.superview];
    [_talkOptionsViewController didMoveToParentViewController:self];
    [_talkOptionsViewController endAppearanceTransition];
    _talkOptionsViewController.view.hidden = YES;
    [_talkOptionsViewController initTalkOptions];
    
    _blackoutView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _blackoutView.frame = self.view.frame;
    _blackoutView.hidden = YES;
    [self.view insertSubview:_blackoutView belowSubview:_talkOptionsViewController.view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCallChatButtons)];
    [_blackoutView addGestureRecognizer:tap];
}

#pragma mark - Agency Status 

- (void)userDidLeaveAgency:(NSNotification *)notification {
    
}

- (void)userDidEnterAgency:(NSNotification *)notification {
    
}

#pragma mark - MBXRaster

//- (void)initMapBoxOverlays {
//    
//    // Configure the amount of storage to use for NSURLCache's shared cache: You can also omit this and allow NSURLCache's
//    // to use its default cache size. These sizes determines how much storage will be used for performance caching of HTTP
//    // requests made by MBXOfflineMapDownloader and MBXRasterTileOverlay. Please note that these values apply only to the
//    // HTTP cache, and persistent offline map data is stored using an entirely separate mechanism.
//    //
//    NSUInteger memoryCapacity = 4 * 1024 * 1024;
//    NSUInteger diskCapacity = 40 * 1024 * 1024;
//    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:nil];
//    //[urlCache removeAllCachedResponses];
//    [NSURLCache setSharedURLCache:urlCache];
//    
//    [MBXMapKit setAccessToken:@"pk.eyJ1IjoiYWRhbXNoYXJlIiwiYSI6ImNvWUtodTQifQ.KdVngge_lPq-xj0bOVxpSw"];
//    
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    
//    // Configure a raster tile overlay to use the initial sample map
//    //
//    _rasterOverlay = [[MBXRasterTileOverlay alloc] initWithMapID:@"adamshare.k610je3e"];
//    
//    // Let the raster tile overlay know that we want to be notified when it has asynchronously loaded the sample map's metadata
//    // (so we can set the map's center and zoom) and the sample map's markers (so we can add them to the map).
//    //
//    _rasterOverlay.delegate = self;
//    
//    // Add the raster tile overlay to our mapView so that it will immediately start rendering tiles. At this point the MKMapView's
//    // default center and zoom don't match the center and zoom of the sample map, but that's okay. Adding the layer now will prevent
//    // a percieved visual glitch in the UI (an empty map), and we'll fix the center and zoom when tileOverlay:didLoadMetadata:withError:
//    // gets called to notify us that the raster tile overlay has finished asynchronously loading its metadata.
//    //
//    [_mapView addOverlay:_rasterOverlay];
//    
//}
//
//#pragma mark - MBXRasterTileOverlayDelegate implementation
//
//- (void)tileOverlay:(MBXRasterTileOverlay *)overlay didLoadMetadata:(NSDictionary *)metadata withError:(NSError *)error
//{
//    // This delegate callback is for centering the map once the map metadata has been loaded
//    //
//    if (error)
//    {
//        NSLog(@"Failed to load metadata for map ID %@ - (%@)", overlay.mapID, error?error:@"");
//    }
//    else
//    {
//        [_mapView mbx_setCenterCoordinate:overlay.center zoomLevel:overlay.centerZoom animated:NO];
//    }
//}
//
//
//- (void)tileOverlay:(MBXRasterTileOverlay *)overlay didLoadMarkers:(NSArray *)markers withError:(NSError *)error
//{
//    // This delegate callback is for adding map markers to an MKMapView once all the markers for the tile overlay have loaded
//    //
//    if (error)
//    {
//        NSLog(@"Failed to load markers for map ID %@ - (%@)", overlay.mapID, error?error:@"");
//    }
//    else
//    {
//        [_mapView addAnnotations:markers];
//    }
//}
//
//- (void)tileOverlayDidFinishLoadingMetadataAndMarkers:(MBXRasterTileOverlay *)overlay
//{
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//}


@end
