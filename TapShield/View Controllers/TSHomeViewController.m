//
//  TSHomeViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHomeViewController.h"
#import "TSCustomMapAnnotationUserLocation.h"

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
    
    [_locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [_mapView setRegionAtAppearance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastReportedLocation = [locations lastObject];
    
    
    
    if (!_mapView.initialLocation) {
        _mapView.initialLocation = lastReportedLocation;
        [_mapView updateAccuracyCircleWithLocation:lastReportedLocation];
    }
    
    
    
    
    if (!_mapView.userLocationAnnotation) {
        _mapView.userLocationAnnotation = [[TSCustomMapAnnotationUserLocation alloc] initWithCoordinates:lastReportedLocation.coordinate
                                                                                       placeName:[NSString stringWithFormat:@"%f, %f", lastReportedLocation.coordinate.latitude, lastReportedLocation.coordinate.longitude]
                                                                                     description:[NSString stringWithFormat:@"Accuracy: %f", lastReportedLocation.horizontalAccuracy]];
        [_mapView addAnnotation:_mapView.userLocationAnnotation];
        
    }
    else {
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _mapView.userLocationAnnotation.coordinate = lastReportedLocation.coordinate;
                         } completion:^(BOOL finished) {
                             [_mapView updateAccuracyCircleWithLocation:lastReportedLocation];
                         }];
    }
    
    [_geocoder reverseGeocodeLocation:_locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks) {
            CLPlacemark *placemark = [placemarks firstObject];
            _mapView.userLocationAnnotation.title = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
            _mapView.userLocationAnnotation.subtitle = [NSString stringWithFormat:@"%@, %@ %@", placemark.locality, placemark.administrativeArea, placemark.postalCode];
        }
    }];
    
    [_mapView setCenterCoordinate:lastReportedLocation.coordinate animated:YES];
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



@end
