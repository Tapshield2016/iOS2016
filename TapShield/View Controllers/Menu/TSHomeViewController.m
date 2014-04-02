//
//  TSHomeViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHomeViewController.h"
#import "TSDestinationSearchViewController.h"
#import <MapKit/MapKit.h>
#import "TSSelectedDestinationLeftCalloutAccessoryView.h"
#import "TSUtilities.h"
#import "TSIntroPageViewController.h"
#import "TSPhoneVerificationViewController.h"

@interface TSHomeViewController ()

@property (nonatomic, strong) TSTransitionDelegate *transitionController;
@property (nonatomic) BOOL viewDidAppear;

@end

@implementation TSHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _entourageManager = [[TSVirtualEntourageManager alloc] initWithMapView:_mapView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapshield_icon"]];
    imageView.contentMode = UIViewContentModeCenter;
    _yankBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Yank_icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.titleView = imageView;
    self.navigationItem.rightBarButtonItem = _yankBarButton;
    
    _transitionController = [[TSTransitionDelegate alloc] init];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRecognizer setDelegate:self];
    [_mapView addGestureRecognizer:panRecognizer];

    // Tap recognizer for selecting routes and other items
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [_mapView addGestureRecognizer:recognizer];

    _geocoder = [[CLGeocoder alloc] init];
    
    if (![[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser]) {
        [self presentViewControllerWithClass:[TSIntroPageViewController class] transitionDelegate:nil animated:NO];
    }
    else if (![[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].phoneNumberVerified) {
        [self presentViewControllerWithClass:[TSPhoneVerificationViewController class] transitionDelegate:nil animated:NO];
    }
    
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
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    [self showAllSubviews];
    
    //To determine animation of first region
    _viewDidAppear = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearEntourageAndResetMap {
    
    [_entourageManager removeRouteOverlays];
    [_mapView removeCurrentDestinationAnnotation];
    self.isTrackingUser = YES;
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
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        for (int i = 0; i < recognizer.numberOfTouches; i++) {
            CGPoint point = [recognizer locationOfTouch:i inView:_mapView];

            CLLocationCoordinate2D coord = [_mapView convertPoint:point toCoordinateFromView:_mapView];
            MKMapPoint mapPoint = MKMapPointForCoordinate(coord);

            [_entourageManager selectRouteClosestTo:mapPoint];
        }
    }
}

#pragma mark - Virtual Entourage methods

- (IBAction)displayVirtualEntourage:(id)sender {
    
    UIViewController *viewController = [self presentViewControllerWithClass:[TSDestinationSearchViewController class] transitionDelegate:_transitionController animated:YES];
    ((TSDestinationSearchViewController *)viewController).homeViewController = self;
    
    [self showOnlyMap];
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
        [_mapView setCenterCoordinate:location.coordinate animated:YES];
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
    [renderer setLineWidth:4.0];
    [renderer setStrokeColor:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.5]];
    
    if (!_entourageManager.selectedRoute) {
        _entourageManager.selectedRoute = [_entourageManager.routes firstObject];
    }
    
    if (_entourageManager.selectedRoute) {
        for (MKRoute *route in _entourageManager.routes) {
            if (route == _entourageManager.selectedRoute) {
                if (route.polyline == overlay) {
                    NSLog(@"%@ highlighted", route.name);
                    [renderer setStrokeColor:[TSColorPalette tapshieldBlue]];
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
    
    if ([annotation isKindOfClass:[TSUserLocationAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"user"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"user"];
        }
        annotationView.image = [UIImage imageNamed:@"user_icon"];
        [annotationView setCanShowCallout:YES];

        return annotationView;
    }
    else if ([annotation isKindOfClass:[TSAgencyAnnotation class]]) {

        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:((TSAgencyAnnotation *)annotation).subtitle];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"agency"];
        }

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/5)];
        label.text = ((TSAgencyAnnotation *)annotation).title;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor darkGrayColor];
        [annotationView addSubview:label];
        annotationView.frame = label.frame;
        annotationView.alpha = 0.0f;
        
        return annotationView;
    }
    else if ([annotation isKindOfClass:[TSSelectedDestinationAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSSelectedDestinationAnnotation class])];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSSelectedDestinationAnnotation class])];
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TSSelectedDestinationLeftCalloutAccessoryView" owner:self options:nil];
            TSSelectedDestinationLeftCalloutAccessoryView *leftCalloutAccessoryView = views[0];
            annotationView.leftCalloutAccessoryView = leftCalloutAccessoryView;
        }
        annotationView.annotation = annotation;
        annotationView.image = [UIImage imageNamed:@"pins_other_icon"];
        annotationView.centerOffset = CGPointMake(0, -annotationView.image.size.height / 2);
        ((TSSelectedDestinationLeftCalloutAccessoryView *)annotationView.leftCalloutAccessoryView).minutes.text = @"";
        [annotationView setCanShowCallout:YES];

//        [self calculateETAForSelectedDestination:^(NSTimeInterval expectedTravelTime) {
//            if (expectedTravelTime) {
//                ((TSSelectedDestinationLeftCalloutAccessoryView *)annotationView.leftCalloutAccessoryView).minutes.text = [TSUtilities formattedStringForDuration:expectedTravelTime];
//            }
//        }];

        return annotationView;
    }
    else if ([annotation isKindOfClass:[TSRouteTimeAnnotation class]]) {
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSRouteTimeAnnotation class])];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([TSRouteTimeAnnotation class])];
        }
        annotationView.image = [UIImage imageNamed:@"bubble_time_LB_icon"];
        annotationView.centerOffset = CGPointMake(annotationView.image.size.width / 2, -annotationView.image.size.height / 2);
        
        UILabel *etaLabel = [[UILabel alloc] initWithFrame:annotationView.bounds];
        etaLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:10.0f];
        etaLabel.textColor = [TSColorPalette whiteColor];
        etaLabel.textAlignment = NSTextAlignmentCenter;
        etaLabel.text = ((TSRouteTimeAnnotation *)annotation).title;
        
        [annotationView addSubview:etaLabel];
        [annotationView setCanShowCallout:NO];
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = YES;
    
    [_mapView adjustAnnotationAlphaForPan];
    
    [_mapView removeAnimatedOverlay];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = NO;
    
    [_mapView addAnimatedOverlayToAnnotation:_mapView.userLocationAnnotation];
    
    CLLocation *location = [TSLocationController sharedLocationController].location;
    if (_isTrackingUser) {
        //avoid loop from negligible differences in region change during zoom
        if (fabs(_mapView.region.center.latitude - location.coordinate.latitude) >= .0000001 ||
            fabs(_mapView.region.center.longitude - location.coordinate.longitude) >= .0000001) {
            [_mapView setCenterCoordinate:location.coordinate animated:YES];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    _mapView.shouldUpdateCallOut = YES;
    
    [self geocoderUpdateUserLocationAnnotationCallOutForLocation:[TSLocationController sharedLocationController].location];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    _mapView.shouldUpdateCallOut = NO;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [mapView deselectAnnotation:view.annotation animated:YES];
//    [self requestAndDisplayRoutesForSelectedDestination];
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    
    NSLog(@"Failed Loading Map");
}

#pragma mark - Alert Methods


- (IBAction)sendAlert:(id)sender {
    
    [self presentViewControllerWithClass:[TSPageViewController class] transitionDelegate:_transitionController animated:YES];
}

- (IBAction)openChatWindow:(id)sender {
    
    [self presentViewControllerWithClass:[TSChatViewController class] transitionDelegate:_transitionController animated:YES];
}




@end
