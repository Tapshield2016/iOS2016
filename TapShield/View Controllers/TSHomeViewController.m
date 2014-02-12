//
//  TSHomeViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHomeViewController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _geocoder = [[CLGeocoder alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
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

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastReportedLocation = [locations lastObject];
    
    NSLog(@"%f", lastReportedLocation.horizontalAccuracy);
    
    _mapView.currentLocation = lastReportedLocation;
    
    if (!_mapView.initialLocation) {
        _mapView.initialLocation = lastReportedLocation;
    }
    
    if (!_mapView.userLocationAnnotation) {
        _mapView.userLocationAnnotation = [[TSCustomMapAnnotationUserLocation alloc] initWithCoordinates:lastReportedLocation.coordinate
                                                                                       placeName:[NSString stringWithFormat:@"%f, %f", lastReportedLocation.coordinate.latitude, lastReportedLocation.coordinate.longitude]
                                                                                     description:[NSString stringWithFormat:@"Accuracy: %f", lastReportedLocation.horizontalAccuracy]];
        [_mapView addAnnotation:_mapView.userLocationAnnotation];
        
    }
    else {
        
        [_mapView removeOverlay:_mapView.accuracyCircle];
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _mapView.userLocationAnnotation.coordinate = lastReportedLocation.coordinate;
                         } completion:nil];
    }
    
    
    
    if (!_mapView.isAnimatingToRegion) {
        [_mapView setCenterCoordinate:lastReportedLocation.coordinate animated:YES];
    }
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
    
    // use your custom annotation
    if ([annotation isKindOfClass:[TSCustomMapAnnotationUserLocation class]]) {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"user"];
        annotationView.image = [UIImage imageNamed:@"logo"];
        [annotationView setCanShowCallout:YES];
        
        return annotationView;
    }
    
    // use default annotation
    return nil;
    
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = YES;
    
    [_mapView updateAccuracyCircleWithLocation:_locationManager.location];
    [_mapView removeAnimatedOverlay];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    _mapView.isAnimatingToRegion = NO;
    
    for(TSCustomMapAnnotationUserLocation *n in _mapView.annotations){
        [_mapView addAnimatedOverlayToAnnotation:n];
    }
    
    [_mapView removeOverlay:_mapView.accuracyCircle];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    [_geocoder reverseGeocodeLocation:_locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks) {
            CLPlacemark *placemark = [placemarks firstObject];
            _mapView.userLocationAnnotation.title = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
            _mapView.userLocationAnnotation.subtitle = [NSString stringWithFormat:@"%@, %@ %@", placemark.locality, placemark.administrativeArea, placemark.postalCode];
        }
    }];
}

@end
