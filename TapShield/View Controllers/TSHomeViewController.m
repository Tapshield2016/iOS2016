//
//  TSHomeViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHomeViewController.h"
#import "TSVirtualEntourageViewController.h"

@interface TSHomeViewController ()



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
    
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0.0f, 0.0f, _bottomButtonContainerView.frame.size.width, 0.5f);
    TopBorder.backgroundColor = [TSColorPalette colorByAdjustingColor:[UIColor blackColor] Alpha:0.3f].CGColor;
    [_bottomButtonContainerView.layer addSublayer:TopBorder];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRecognizer setDelegate:self];
    [self.mapView addGestureRecognizer:panRecognizer];
    
    _geocoder = [[CLGeocoder alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.distanceFilter = 5.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    TSAppDelegate *appDelegate = (TSAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.currentLocation) {
        [_mapView setRegionAtAppearanceAnimated:NO];
        _mapView.initialLocation = appDelegate.currentLocation;
    }
    
    // Display user location and selected destination if present
    if (_mapView.destinationAnnotation) {
        [_mapView showAnnotations:@[_mapView.userLocationAnnotation, _mapView.destinationAnnotation] animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [_locationManager startUpdatingLocation];
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
            [_mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
        }
    }
}

- (IBAction)displayVirtualEntourage:(id)sender {
    UINavigationController *navController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TSVirtualEntourageNavigationController"];
    ((TSVirtualEntourageViewController *)navController.viewControllers[0]).mapView = _mapView;
    [self presentViewController:navController animated:YES completion:^{
        NSLog(@"Hey...");
    }];
}


#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    TSAppDelegate *appDelegate = (TSAppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation *lastReportedLocation = [locations lastObject];
    appDelegate.currentLocation = lastReportedLocation;
    
    NSLog(@"%f", lastReportedLocation.horizontalAccuracy);
    
    _mapView.currentLocation = lastReportedLocation;
    
    if (!_mapView.initialLocation) {
        _mapView.initialLocation = lastReportedLocation;
        [_mapView setRegionAtAppearanceAnimated:YES];
    }
    
    if (!_mapView.userLocationAnnotation) {
        _mapView.userLocationAnnotation = [[TSCustomMapAnnotationUserLocation alloc] initWithCoordinates:lastReportedLocation.coordinate
                                                                                       placeName:[NSString stringWithFormat:@"%f, %f", lastReportedLocation.coordinate.latitude, lastReportedLocation.coordinate.longitude]
                                                                                     description:[NSString stringWithFormat:@"Accuracy: %f", lastReportedLocation.horizontalAccuracy]];
        [_mapView addAnnotation:_mapView.userLocationAnnotation];
        [_mapView updateAccuracyCircleWithLocation:_locationManager.location];
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapView updateAccuracyCircleWithLocation:_locationManager.location];
        });
        _mapView.userLocationAnnotation.coordinate = lastReportedLocation.coordinate;
        
//        [_mapView removeOverlay:_mapView.accuracyCircle];
//        
//        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseIn
//                         animations:^{
//                             _mapView.userLocationAnnotation.coordinate = lastReportedLocation.coordinate;
//                         } completion:nil];
    }
    
    
    
    if (!_mapView.isAnimatingToRegion && _showUserLocationButton.selected) {
        [_mapView setCenterCoordinate:lastReportedLocation.coordinate animated:YES];
    }
    
    if ([_mapView.lastReverseGeocodeLocation distanceFromLocation:lastReportedLocation] > 15 && _mapView.shouldUpdateCallOut) {
        [self geocoderUpdateUserLocationAnnotationCallOutForLocation:lastReportedLocation];
    }
    
    _mapView.previousLocation = lastReportedLocation;
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

//Enable show user location
//
//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
//    if (!_mapView.initialLocation) {
//        _mapView.initialLocation = userLocation.location;
//    }
//    
//    [_geocoder reverseGeocodeLocation:_locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
//        if (placemarks) {
//            CLPlacemark *placemark = [placemarks firstObject];
//            _mapView.userLocation.title = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
//            _mapView.userLocation.subtitle = [NSString stringWithFormat:@"%@, %@ %@", placemark.locality, placemark.administrativeArea, placemark.postalCode];
//        }
//    }];
//    
//    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
//}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if([overlay isKindOfClass:[MKPolygon class]]){
        return [TSMapView mapViewPolygonOverlay:overlay];
    }
    if ([overlay isKindOfClass:[MKCircle class]]) {
        
        return [TSMapView mapViewCircleOverlay:overlay];
    }
    
    return nil;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[TSCustomMapAnnotationUserLocation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"user"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"user"];
        }
        annotationView.image = [UIImage imageNamed:@"logo"];
        [annotationView setCanShowCallout:YES];
        
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[TSAgencyAnnotation class]]) {
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:((TSAgencyAnnotation *)annotation).subtitle];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:((TSAgencyAnnotation *)annotation).subtitle];
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
    
    return nil;
}


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = YES;
    
    [_mapView adjustAnnotationAlphaForPan];
    
    [_mapView removeAnimatedOverlay];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = NO;
    
    for(TSCustomMapAnnotationUserLocation *n in _mapView.annotations){
        [_mapView addAnimatedOverlayToAnnotation:n];
    }
    
    //[_mapView removeOverlay:_mapView.accuracyCircle];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    _mapView.shouldUpdateCallOut = YES;
    
    [self geocoderUpdateUserLocationAnnotationCallOutForLocation:_locationManager.location];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    _mapView.shouldUpdateCallOut = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"drag ended");
        _showUserLocationButton.selected = NO;
    }
}


@end
