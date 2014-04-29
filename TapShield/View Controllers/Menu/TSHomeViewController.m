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

@interface TSHomeViewController ()

@property (nonatomic, strong) TSTransitionDelegate *transitionController;
@property (nonatomic) BOOL viewDidAppear;
@property (strong, nonatomic) UIAlertView *cancelEntourageAlertView;

@end

@implementation TSHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self checkLoggedInUser];
    
    self.showSmallLogoInNavBar = YES;
    _mapView.isAnimatingToRegion = YES;
    
    _entourageManager = [[TSVirtualEntourageManager alloc] initWithHomeView:self];
    
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
    
    [TSLocationController sharedLocationController].delegate = self;
    [[TSLocationController sharedLocationController] startStandardLocationUpdates:^(CLLocation *location) {
        [_mapView setRegionAtAppearanceAnimated:_viewDidAppear];
        
        if (!_mapView.userLocationAnnotation) {
            _mapView.userLocationAnnotation = [[TSUserLocationAnnotation alloc] initWithCoordinates:location.coordinate
                                                                                          placeName:[NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude]
                                                                                        description:[NSString stringWithFormat:@"Accuracy: %f", location.horizontalAccuracy]];
            
            [_mapView addAnnotation:_mapView.userLocationAnnotation];
            [_mapView updateAccuracyCircleWithLocation:location];
        }
    }];
    
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
        [self performSelector:@selector(sendAlert:) withObject:self];
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
    else if (![[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].phoneNumberVerified) {
        [self presentViewControllerWithClass:[TSPhoneVerificationViewController class] transitionDelegate:nil animated:NO];
    }
}

#pragma mark - UI Changes

- (void)mapAlertModeToggle {
    
    [_mapView updateAccuracyCircleWithLocation:[TSLocationController sharedLocationController].location];
    [_mapView resetAnimatedOverlayAt:[TSLocationController sharedLocationController].location];
}

- (void)entourageModeOn {
    
    [self setIsTrackingUser:YES];
    [self drawerCanDragForMenu:NO];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEntourage)];
    [barButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue],
                                        NSFontAttributeName :[TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f]} forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:barButton animated:YES];
}

- (void)clearEntourageAndResetMap {
    
    [_menuViewController showMenuButton:self];
    [_entourageManager stopEntourage];
    [self drawerCanDragForMenu:YES];
    self.isTrackingUser = YES;
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
    
    if (self.presentedViewController) {
        if ([self.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)self.presentedViewController;
            
            //already presented
            if ([nav.topViewController isKindOfClass:[TSPageViewController class]]) {
                return;
            }
            //dismiss any view presented first
            else {
                [nav.topViewController dismissViewControllerAnimated:YES completion:^{
                    [self performSelectorOnMainThread:@selector(sendAlert:) withObject:nil waitUntilDone:NO];
                }];
                return;
            }
        }
    }
    
    TSPageViewController *pageview = (TSPageViewController *)[self presentViewControllerWithClass:[TSPageViewController class] transitionDelegate:_transitionController animated:YES];
    pageview.homeViewController = self;
    
    _isTrackingUser = YES;
    [_mapView setRegionAtAppearanceAnimated:YES];
    
    [self showOnlyMap];
}

- (IBAction)openChatWindow:(id)sender {
    
    [self presentViewControllerWithClass:[TSChatViewController class] transitionDelegate:_transitionController animated:YES];
}

- (IBAction)reportAlert:(id)sender {
    
    [self presentViewControllerWithClass:[TSAlertDetailsTableViewController class] transitionDelegate:nil animated:YES];
}

- (IBAction)displayVirtualEntourage:(id)sender {
    
    if (!_entourageManager.isEnabled) {
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
    
    if (_entourageManager.isEnabled ) {
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
            [_entourageManager.routeManager selectRouteClosestTo:mapPoint];
        }
    }
}




#pragma mark - TSLocationControllerDelegate methods

- (void)locationDidUpdate:(CLLocation *)location {
    
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
    [_mapView resetAnimatedOverlayAt:location];
}

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
    
    if (!_entourageManager.routeManager.selectedRoute) {
        _entourageManager.routeManager.selectedRoute = [_entourageManager.routeManager.routeOptions firstObject];
    }
    
    if (_entourageManager.routeManager.selectedRoute) {
        for (TSRouteOption *routeOption in _entourageManager.routeManager.routeOptions) {
            if (routeOption == _entourageManager.routeManager.selectedRoute) {
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
    }
    else if ([annotation isKindOfClass:[TSAgencyAnnotation class]]) {

        annotationView = (TSOrganizationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSAgencyAnnotation class])];
        if (!annotationView) {
            annotationView = [[TSOrganizationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSAgencyAnnotation class])];
        }
        ((TSOrganizationAnnotationView *)annotationView).label.text = ((TSAgencyAnnotation *)annotation).title;
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
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
    [self flipIntersectingRouteAnnotation];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = YES;
    
    [_mapView adjustAnnotationAlphaForPan];
    
    [_mapView removeAnimatedOverlay];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = NO;
    
    [_mapView resetAnimatedOverlayAt:[TSLocationController sharedLocationController].location];
    
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
    }
    
    if ([view isKindOfClass:[TSRouteTimeAnnotationView class]]) {
        [_entourageManager.routeManager selectedRouteAnnotationView:(TSRouteTimeAnnotationView *)view];
        [self flipIntersectingRouteAnnotation];
    }
    
    [self geocoderUpdateUserLocationAnnotationCallOutForLocation:[TSLocationController sharedLocationController].location];
    
    [_mapView bringSubviewToFront:view];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    if ([view isKindOfClass:[TSUserAnnotationView class]]) {
        _mapView.shouldUpdateCallOut = NO;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [mapView deselectAnnotation:view.annotation animated:YES];
//    [self requestAndDisplayRoutesForSelectedDestination];
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
                        if ([((TSRouteTimeAnnotationView *)annotationView).annotation isEqual:_entourageManager.routeManager.selectedRoute.routeTimeAnnotation]) {
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
            [self clearEntourageAndResetMap];
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
