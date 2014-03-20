//
//  TSHomeViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHomeViewController.h"
#import "TSVirtualEntourageViewController.h"
#import <MapKit/MapKit.h>
#import "TSSelectedDestinationLeftCalloutAccessoryView.h"
#import "TSUtilities.h"
#import "TSIntroPageViewController.h"
#import "TSPhoneVerificationViewController.h"

@interface TSHomeViewController ()

@property (nonatomic, strong) TSTransitionDelegate *transitionController;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) MKRoute *selectedRoute;
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

    // Display user location and selected destination if present
    if (_mapView.destinationMapItem) {
#warning Need to find a better way of turning on/off keeping the user in the center
        _showUserLocationButton.selected = NO;
        [_mapView centerMapOnSelectedDestination];
        [_mapView selectDestinationAnnotation];
    }
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    //To determine animation of first region
    _viewDidAppear = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userLocationTUI:(id)sender {
    _showUserLocationButton.selected = !_showUserLocationButton.selected;
    
    if (_showUserLocationButton.selected) {
        if (_mapView.region.span.latitudeDelta > 0.1f) {
            [_mapView setRegionAtAppearanceAnimated:YES];
        }
        else {
            [_mapView setCenterCoordinate:[TSLocationController sharedLocationController].location.coordinate animated:YES];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Gesture handlers

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"drag ended");
        _showUserLocationButton.selected = NO;
    }
}

- (void)handleTap:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        for (int i = 0; i < recognizer.numberOfTouches; i++) {
            CGPoint point = [recognizer locationOfTouch:i inView:_mapView];

            CLLocationCoordinate2D coord = [_mapView convertPoint:point toCoordinateFromView:_mapView];
            MKMapPoint mapPoint = MKMapPointForCoordinate(coord);

            // Capture multiple routes in case of overlap
            NSMutableArray *struckRoutes = [[NSMutableArray alloc] initWithCapacity:4];
            for (id overlay in _mapView.overlays) {
                if ([overlay isKindOfClass:[MKPolyline class]]) {
                    MKPolyline *poly = (MKPolyline *) overlay;
                    id view = [_mapView rendererForOverlay:poly];

                    if ([view isKindOfClass:[MKPolylineRenderer class]]) {
                        MKPolylineRenderer *polyView = (MKPolylineRenderer*) view;
                        [polyView invalidatePath];

                        CGPoint polygonViewPoint = [polyView pointForMapPoint:mapPoint];
                        BOOL mapCoordinateIsInPolygon = CGPathContainsPoint(polyView.path, NULL, polygonViewPoint, NO);

                        if (mapCoordinateIsInPolygon) {
                            for (MKRoute *route in _routes) {
                                if (route.polyline == poly) {
                                    [struckRoutes addObject:route];
                                }
                            }
                        }
                    }
                }
            }

            [self setSelectedRouteFromStruckRoutes:struckRoutes];
        }
    }
}

#pragma mark - Virtual Entourage methods

- (IBAction)displayVirtualEntourage:(id)sender {
    UINavigationController *navController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TSVirtualEntourageNavigationController"];
    ((TSVirtualEntourageViewController *)navController.viewControllers[0]).mapView = _mapView;
    [self presentViewController:navController animated:YES completion:^{

    }];
}


#pragma mark - Route management and display methods

- (void)setSelectedRouteFromStruckRoutes:(NSMutableArray *)struckRoutes {
    if ([struckRoutes count] > 0) {
        // If only one route, just take that one
        if ([struckRoutes count] == 1) {
            _selectedRoute = struckRoutes[0];
        }
        else {
            // If multiple overlapping routes, alternate if one is already selected
            BOOL previouslySelectedRouteWasStruck = NO;
            for (MKRoute *route in struckRoutes) {
                if (_selectedRoute == route) {
                    NSUInteger selectedIndex = [struckRoutes indexOfObject:route];
                    _selectedRoute = struckRoutes[(selectedIndex + 1) % struckRoutes.count];
                    previouslySelectedRouteWasStruck = YES;
                    break;
                }
            }
            // Otherwise, just take the first one
            if (!previouslySelectedRouteWasStruck) {
                _selectedRoute = struckRoutes[0];
            }
        }
        NSLog(@"%@ selected", _selectedRoute.name);
        [self refreshOverlays];
    }
}

- (void)calculateETAForSelectedDestination:(void (^)(NSTimeInterval expectedTravelTime))completion {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:_mapView.destinationMapItem];
    [request setTransportType:_mapView.destinationTransportType]; // This can be limited to automobile and walking directions.
    [request setRequestsAlternateRoutes:YES]; // Gives you several route options.
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
            if ((error.code == MKErrorPlacemarkNotFound || error.code == MKErrorDirectionsNotFound) && _mapView.destinationTransportType == MKDirectionsTransportTypeWalking) {
                NSLog(@"Error with walking directions, trying again with 'Any'");
                _mapView.destinationTransportType = MKDirectionsTransportTypeAny;
                [self calculateETAForSelectedDestination:completion];
            }
        }
    }];
}

- (void)requestAndDisplayRoutesForSelectedDestination {
    [_mapView showAnnotations:@[_mapView.userLocationAnnotation, _mapView.destinationAnnotation] animated:YES];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:_mapView.destinationMapItem];
    [request setTransportType:_mapView.destinationTransportType]; // This can be limited to automobile and walking directions.
    [request setRequestsAlternateRoutes:YES]; // Gives you several route options.
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            _selectedRoute = nil;
            [self removeRouteOverlays];
            _routes = [response routes];
            [self addRouteOverlaysToMapView];
        }
    }];
}

- (void)removeRouteOverlays {
    NSMutableArray *overlays = [[NSMutableArray alloc] initWithCapacity:[_routes count]];

    for (MKRoute *route in _routes) {
        [overlays addObject:route.polyline];
    }

    [_mapView removeOverlays:overlays];
}

- (void)addRouteOverlaysToMapView {
    for (MKRoute *route in _routes) {
        if (route == _selectedRoute) {
            // skip selected route so we can add it last, on top of others
            // this handles when two routes overlap
            continue;
        }
        [_mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads]; // Draws the route above roads, but below labels.
        // You can also get turn-by-turn steps, distance, advisory notices, ETA, etc by accessing various route properties.
        //NSLog(@"%f minutes", ceil(route.expectedTravelTime / 60));
        //NSLog(@"%.02f miles", route.distance * 0.000621371);
    }

    if (_selectedRoute) {
        // Add last to counter possible overlap preventing display
        [_mapView addOverlay:[_selectedRoute polyline] level:MKOverlayLevelAboveRoads];
    }
}

- (void)refreshOverlays {
    [self removeRouteOverlays];
    [self addRouteOverlaysToMapView];
}

- (MKPolylineRenderer *)rendererForRoutePolyline:(id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    [renderer setLineWidth:4.0];
    [renderer setStrokeColor:[UIColor lightGrayColor]];
    
    if (_selectedRoute) {
        for (MKRoute *route in _routes) {
            if (route == _selectedRoute) {
                if (route.polyline == overlay) {
                    NSLog(@"%@ highlighted", route.name);
                    [renderer setStrokeColor:[UIColor blueColor]];
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

    if (!_mapView.isAnimatingToRegion && _showUserLocationButton.selected) {
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[TSUserLocationAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"user"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"user"];
        }
        annotationView.image = [UIImage imageNamed:@"logo"];
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
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"TSSelectedDestinationAnnotation"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TSSelectedDestinationAnnotation"];
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TSSelectedDestinationLeftCalloutAccessoryView" owner:self options:nil];
            TSSelectedDestinationLeftCalloutAccessoryView *leftCalloutAccessoryView = views[0];
            annotationView.leftCalloutAccessoryView = leftCalloutAccessoryView;
        }
        annotationView.annotation = annotation;
        annotationView.image = [UIImage imageNamed:@"logo"];
        ((TSSelectedDestinationLeftCalloutAccessoryView *)annotationView.leftCalloutAccessoryView).minutes.text = @"";
        [annotationView setCanShowCallout:YES];

        [self calculateETAForSelectedDestination:^(NSTimeInterval expectedTravelTime) {
            if (expectedTravelTime) {
                ((TSSelectedDestinationLeftCalloutAccessoryView *)annotationView.leftCalloutAccessoryView).minutes.text = [TSUtilities formattedStringForDuration:expectedTravelTime];
            }
        }];

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
    if (_showUserLocationButton.selected) {
        //avoid loop from negligible differences in region change during zoom
        if (fabs(_mapView.region.center.latitude - location.coordinate.latitude) >= .0000001 ||
            fabs(_mapView.region.center.longitude - location.coordinate.longitude) >= .0000001) {
            [_mapView setCenterCoordinate:location.coordinate animated:YES];
        }
    }

    for(TSUserLocationAnnotation *n in _mapView.annotations){
        [_mapView addAnimatedOverlayToAnnotation:n];
    }
    
    //[_mapView removeOverlay:_mapView.accuracyCircle];
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
    [self requestAndDisplayRoutesForSelectedDestination];
}


#pragma mark - Alert Methods


- (IBAction)sendAlert:(id)sender {
    
    [self presentViewControllerWithClass:[TSPageViewController class] transitionDelegate:_transitionController animated:YES];
}

- (IBAction)openChatWindow:(id)sender {
    
    [self presentViewControllerWithClass:[TSChatViewController class] transitionDelegate:_transitionController animated:YES];
}




@end
