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
#import "TSPhoneVerificationViewController.h"
#import "TSRouteTimeAnnotationView.h"
#import "TSOrganizationAnnotationView.h"
#import "TSUserAnnotationView.h"
#import "TSDestinationAnnotationView.h"
#import "TSPageViewController.h"
#import "TSAlertDetailsTableViewController.h"
#import "TSYankManager.h"
#import "TSSpotCrimeAPIClient.h"
#import "TSSpotCrimeAnnotationView.h"
#import "TSNamePictureViewController.h"
#import "TSGeofence.h"
#import "TSViewReportDetailsViewController.h"

@interface TSHomeViewController ()

@property (nonatomic, strong) TSTransitionDelegate *transitionController;
@property (nonatomic) BOOL viewDidAppear;
@property (strong, nonatomic) UIAlertView *cancelEntourageAlertView;
@property (strong, nonatomic) TSBaseLabel *timerLabel;
@property (assign, nonatomic) BOOL annotationsLoaded;

@end

@implementation TSHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _annotationsLoaded = NO;
    
    [self checkLoggedInUser];
    
    self.showSmallLogoInNavBar = YES;
    _mapView.isAnimatingToRegion = YES;
    
    _reportManager = [[TSReportAnnotationManager alloc] initWithMapView:_mapView];
    
    [TSVirtualEntourageManager initSharedEntourageManagerWithHomeView:self];
    
    _yankBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Yank_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleYank:)];
    self.navigationItem.rightBarButtonItem = _yankBarButton;
    
    _transitionController = [[TSTransitionDelegate alloc] init];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRecognizer setDelegate:self];
    [_mapView addGestureRecognizer:panRecognizer];

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
                                             selector:@selector(sendAlert:)
                                                 name:TSYankManagerDidYankHeadphonesNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendAlert:)
                                                 name:TSVirtualEntourageManagerTimerDidEnd
                                               object:nil];
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
    
    [self whiteNavigationBar];
    
    _mapView.isAnimatingToRegion = NO;
    
    [_mapView resetAnimatedOverlayAt:[TSLocationController sharedLocationController].location];
    
    [self showAllSubviews];
    
    //To determine animation of first region
    _viewDidAppear = YES;
    
    if (_shouldSendAlert) {
        [self performSelectorOnMainThread:@selector(sendAlert:) withObject:@"T" waitUntilDone:NO];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    
    [super willMoveToParentViewController:parent];
    
    if (!parent) {
        [TSLocationController sharedLocationController].delegate = nil;
        [[TSVirtualEntourageManager sharedManager] removeHomeViewController];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkLoggedInUser {
    
    if (![[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser]) {
        [self presentViewControllerWithClass:[TSIntroPageViewController class] transitionDelegate:nil animated:NO];
    }
}

- (void)checkUserRegistration {
    
    TSJavelinAPIUser *user = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser];
    if (user) {
        if (!user.phoneNumberVerified) {
            [self presentViewControllerWithClass:[TSPhoneVerificationViewController class] transitionDelegate:nil animated:NO];
        }
        else if (!user.disarmCode || !user.disarmCode.length) {
            [self presentViewControllerWithClass:[TSNamePictureViewController class] transitionDelegate:nil animated:NO];
        }
    }
}

#pragma mark - Map Setup

- (void)addOverlaysAndAnnotations {
    
    [TSLocationController sharedLocationController].delegate = self;
    if (!_annotationsLoaded) {
        _annotationsLoaded = YES;
        
        [_mapView getAllGeofenceBoundaries];
        
        [[TSLocationController sharedLocationController] startStandardLocationUpdates:^(CLLocation *location) {
            
            [_mapView setRegionAtAppearanceAnimated:_viewDidAppear];
            [[TSLocationController sharedLocationController].geofence updateNearbyAgencies:location];
            [_reportManager loadSpotCrimeAndSocialAnnotations:location];
            [self addUserLocationAnnotation:location];
        }];
    }
}

- (void)addUserLocationAnnotation:(CLLocation *)location {
    
    if (!_mapView.userLocationAnnotation) {
        _mapView.userLocationAnnotation = [[TSUserLocationAnnotation alloc] initWithCoordinates:location.coordinate
                                                                                      placeName:[NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude]
                                                                                    description:[NSString stringWithFormat:@"Accuracy: %f", location.horizontalAccuracy]];
        
        [_mapView addAnnotation:_mapView.userLocationAnnotation];
        [_mapView updateAccuracyCircleWithLocation:location];
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
    [self setIsTrackingUser:YES];
    [self drawerCanDragForMenu:NO];
    [self adjustViewableTime];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"End Tracking" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEntourage)];
    [barButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue],
                                        NSFontAttributeName :[TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f]} forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:barButton animated:YES];
}

- (void)clearEntourageAndResetMap {
    
    [_reportManager showSpotCrimes];
    [_menuViewController showMenuButton:self];
    [[TSVirtualEntourageManager sharedManager] stopEntourage];
    [self drawerCanDragForMenu:YES];
    self.isTrackingUser = YES;
    
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
        if (enabled) {
            
        }
        else {
            
        }
    }];
}

- (IBAction)sendAlert:(id)sender {
    
    _shouldSendAlert = NO;
    
    
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
                    [self performSelectorOnMainThread:@selector(sendAlert:) withObject:sender waitUntilDone:NO];
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
    
        [[TSAlertManager sharedManager] startAlertCountdown:10 type:type];
        
        TSPageViewController *pageview = (TSPageViewController *)[self presentViewControllerWithClass:[TSPageViewController class] transitionDelegate:_transitionController animated:YES];
        pageview.homeViewController = self;
        
        _isTrackingUser = YES;
        [_mapView setRegionAtAppearanceAnimated:YES];
        
        [self showOnlyMap];
    });
}

- (IBAction)openChatWindow:(id)sender {
    
    if (![TSLocationController sharedLocationController].geofence.currentAgency) {
        [[TSLocationController sharedLocationController].geofence showOutsideBoundariesWindow];
        return;
    }
    
    TSPageViewController *pageview = (TSPageViewController *)[self presentViewControllerWithClass:[TSPageViewController class] transitionDelegate:_transitionController animated:YES];
    pageview.homeViewController = self;
    pageview.isChatPresentation = YES;
    
    _isTrackingUser = YES;
    [_mapView setRegionAtAppearanceAnimated:YES];
    
    [self showOnlyMap];
}

- (IBAction)reportAlert:(id)sender {
    
    TSAlertDetailsTableViewController *viewController = (TSAlertDetailsTableViewController *)[self presentViewControllerWithClass:[TSAlertDetailsTableViewController class] transitionDelegate:nil animated:YES];
    
    viewController.reportManager = _reportManager;
}

- (IBAction)displayVirtualEntourage:(id)sender {
    
    [_reportManager hideSpotCrimes];
    
    if (![TSVirtualEntourageManager sharedManager].isEnabled) {
        TSDestinationSearchViewController *viewController = (TSDestinationSearchViewController *)[self presentViewControllerWithClass:[TSDestinationSearchViewController class] transitionDelegate:_transitionController animated:YES];
        viewController.homeViewController = self;
        
        [self showOnlyMap];
    }
    else {
        if (!_transitionController) {
            _transitionController = [[TSTransitionDelegate alloc] init];
        }
        
        TSNotifySelectionViewController *viewController = (TSNotifySelectionViewController *)[self presentViewControllerWithClass:[TSNotifySelectionViewController class] transitionDelegate:_transitionController animated:YES];
        viewController.homeViewController = self;
    }
}

- (IBAction)userLocationTUI:(id)sender {
    
    self.isTrackingUser = YES;
}

- (void)setIsTrackingUser:(BOOL)isTrackingUser {
    
    _isTrackingUser = isTrackingUser;
    
    if (isTrackingUser) {
        if (_mapView.region.span.latitudeDelta > 0.1f) {
            [_mapView setRegionAtAppearanceAnimated:YES];
        }
        else {
            [_mapView setCenterCoordinate:[TSLocationController sharedLocationController].location.coordinate animated:YES];
        }
    }
}

- (void)showAllSubviews {
    
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




#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Gesture handlers

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        _isTrackingUser = NO;
    }
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
    
    if ([[TSVirtualEntourageManager sharedManager].endRegion containsCoordinate:location.coordinate]) {
        [[TSVirtualEntourageManager sharedManager] checkRegion:location];
    }
    
    if (!_mapView.userLocationAnnotation) {
        _mapView.userLocationAnnotation = [[TSUserLocationAnnotation alloc] initWithCoordinates:location.coordinate
                                                                                       placeName:[NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude]
                                                                                     description:[NSString stringWithFormat:@"Accuracy: %f", location.horizontalAccuracy]];
        
        [_mapView addAnnotation:_mapView.userLocationAnnotation];
        [_mapView updateAccuracyCircleWithLocation:location];
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapView updateAccuracyCircleWithLocation:location];
        });
        _mapView.userLocationAnnotation.coordinate = location.coordinate;
    }

    if (!_mapView.isAnimatingToRegion && _isTrackingUser) {
        //avoid loop from negligible differences in region change
        if (fabs(_mapView.region.center.latitude - location.coordinate.latitude) >= .0000001 ||
            fabs(_mapView.region.center.longitude - location.coordinate.longitude) >= .0000001) {
            [_mapView setCenterCoordinate:location.coordinate animated:YES];
        }
    }
    
    if ([_mapView.lastReverseGeocodeLocation distanceFromLocation:location] > 15 && _mapView.shouldUpdateCallOut) {
        [self geocoderUpdateUserLocationAnnotationCallOutForLocation:location];
    }
    
    _mapView.previousLocation = location;
    
    if (_viewDidAppear) {
        [_mapView resetAnimatedOverlayAt:location];
    }
}

- (void)didEnterRegion:(CLRegion *)region {
    
}

#pragma mark - User Callout

- (void)geocoderUpdateUserLocationAnnotationCallOutForLocation:(CLLocation *)location {
    
    _mapView.lastReverseGeocodeLocation = location;
    
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
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
            
            _mapView.userLocationAnnotation.title = title;
            _mapView.userLocationAnnotation.subtitle = subtitle;
        }
    }];
}

#pragma mark - MKMapViewDelegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if([overlay isKindOfClass:[MKPolygon class]]){
        return [TSMapView mapViewPolygonOverlay:overlay];
    }
    else if ([overlay isKindOfClass:[MKCircle class]]) {
        
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
        
        NSString *reuseIdentifier = [NSString stringWithFormat:@"%@-%@", [(TSSpotCrimeAnnotation *)annotation spotCrime].type, [TSJavelinAPISocialCrimeReport socialReportTypesToString:[(TSSpotCrimeAnnotation *)annotation socialReport].reportType]];
        
        annotationView = (TSSpotCrimeAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        [annotationView setAnnotation:annotation];
        
        if (!annotationView) {
            annotationView = [[TSSpotCrimeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        
        ((TSSpotCrimeAnnotationView *)annotationView).alpha = [annotationView alphaForReportDate];
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
    [self flipIntersectingRouteAnnotation];
    
    
    
    CGRect visibleRect = [mapView annotationVisibleRect];
    for (TSBaseAnnotationView *view in views) {
        
        if ([view isKindOfClass:[TSBaseAnnotationView class]]) {
            
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
    
    [_mapView adjustAnnotationAlphaForPan];
    
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
            [_mapView setCenterCoordinate:location.coordinate animated:YES];
        }
    }
    
    [self flipIntersectingRouteAnnotation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view isKindOfClass:[TSUserAnnotationView class]]) {
        _mapView.shouldUpdateCallOut = YES;
        
        [self geocoderUpdateUserLocationAnnotationCallOutForLocation:[TSLocationController sharedLocationController].location];
    }
    
    if ([view isKindOfClass:[TSSpotCrimeAnnotationView class]]) {
        view.alpha = 1.0;
        
        NSString *subtitle;
        
        TSSpotCrimeLocation *location = ((TSSpotCrimeAnnotation *)view.annotation).spotCrime;
        TSJavelinAPISocialCrimeReport *report = ((TSSpotCrimeAnnotation *)view.annotation).socialReport;
        
        if (report) {
            subtitle = [TSUtilities dateDescriptionSinceNow:report.creationDate];
        }
        else {
            subtitle = [TSUtilities dateDescriptionSinceNow:location.date];
        }
        
        ((TSSpotCrimeAnnotation *)view.annotation).subtitle = subtitle;
    }
    
    if ([view isKindOfClass:[TSRouteTimeAnnotationView class]]) {
        [[TSVirtualEntourageManager sharedManager].routeManager selectedRouteAnnotationView:(TSRouteTimeAnnotationView *)view];
        [self flipIntersectingRouteAnnotation];
    }
    
    [_mapView bringSubviewToFront:view];
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
        
        TSViewReportDetailsViewController *controller = [TSViewReportDetailsViewController presentDetails:view.annotation
                                                                                                     from:self];
        controller.reportManager = _reportManager;
        
//        TSSpotCrimeLocation *location = ((TSSpotCrimeAnnotation *)view.annotation).spotCrime;
//        TSJavelinAPISocialCrimeReport *report = ((TSSpotCrimeAnnotation *)view.annotation).socialReport;
//        
//        if (location) {
//            if (!location.eventDescription) {
//                
//                [[TSSpotCrimeAPIClient sharedClient] getSpotCrimeDescription:location completion:^(TSSpotCrimeLocation *location) {
//                    
//                    ((TSSpotCrimeAnnotation *)view.annotation).spotCrime = location;
//                    ((TSSpotCrimeAnnotation *)view.annotation).subtitle = location.eventDescription;
//                }];
//            }
//            else {
//                if ([((TSSpotCrimeAnnotation *)view.annotation).subtitle isEqualToString:location.address]) {
//                    ((TSSpotCrimeAnnotation *)view.annotation).subtitle = location.eventDescription;
//                }
//                else {
//                    ((TSSpotCrimeAnnotation *)view.annotation).subtitle = location.address;
//                }
//            }
//        }
//        if (report) {
//            
//            if (!((TSSpotCrimeAnnotation *)view.annotation).subtitle) {
//                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//                [geocoder reverseGeocodeLocation:((TSSpotCrimeAnnotation *)view.annotation).socialReport.location completionHandler:^(NSArray *placemarks, NSError *error) {
//                    if (placemarks) {
//                        CLPlacemark *placemark = [placemarks firstObject];
//                        NSString *title = @"";
//                        NSString *subtitle = @"";
//                        if (placemark.subThoroughfare) {
//                            title = placemark.subThoroughfare;
//                        }
//                        if (placemark.thoroughfare) {
//                            title = [NSString stringWithFormat:@"%@ %@", title, placemark.thoroughfare];
//                        }
//                        if (placemark.locality) {
//                            subtitle = placemark.locality;
//                        }
//                        if (placemark.administrativeArea) {
//                            if (placemark.locality) {
//                                subtitle = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
//                            }
//                            else {
//                                subtitle = placemark.administrativeArea;
//                            }
//                        }
//                        if (placemark.postalCode) {
//                            subtitle = [NSString stringWithFormat:@"%@ %@", subtitle, placemark.postalCode];
//                        }
//                        
//                        if (!title) {
//                            title = subtitle;
//                        }
//                        
//                        ((TSSpotCrimeAnnotation *)view.annotation).subtitle = title;
//                        ((TSSpotCrimeAnnotation *)view.annotation).socialReport.address = title;
//                    }
//                }];
//            }
//            
//            if ([((TSSpotCrimeAnnotation *)view.annotation).subtitle isEqualToString:report.address]) {
//                ((TSSpotCrimeAnnotation *)view.annotation).subtitle = report.body;
//            }
//            else {
//                ((TSSpotCrimeAnnotation *)view.annotation).subtitle = report.address;
//            }
//        }
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
