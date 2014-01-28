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

@property (nonatomic, retain) CLLocation* initialLocation;
@property (nonatomic, retain) TSCustomMapAnnotationUserLocation *userLocationAnnotation;

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
    _mapView.showsBuildings = YES;
    _mapView.showsPointsOfInterest = YES;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

    CLLocationCoordinate2D boundaries[5] = {
        CLLocationCoordinate2DMake(28.539046,-81.370381),
        CLLocationCoordinate2DMake(28.539328,-81.366432),
        CLLocationCoordinate2DMake(28.535558,-81.366003),
        CLLocationCoordinate2DMake(28.535615,-81.371593),
        CLLocationCoordinate2DMake(28.539046,-81.370381),
    };

    MKPolygon *overflowPoly1 = [MKPolygon polygonWithCoordinates:boundaries count:5];
    [_mapView addOverlay:overflowPoly1];
}

- (void)viewWillAppear:(BOOL)animated {
    [_locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastReportedLocation = locations[locations.count - 1];
    if (!_userLocationAnnotation) {
        _userLocationAnnotation = [[TSCustomMapAnnotationUserLocation alloc] initWithCoordinates:lastReportedLocation.coordinate
                                                                                       placeName:@"Your Location"
                                                                                     description:@"Heyyyy"];
        [_mapView addAnnotation:_userLocationAnnotation];
    }
    else {
        [UIView animateWithDuration:0.5f animations:^{
            _userLocationAnnotation.coordinate = lastReportedLocation.coordinate;
        }];
    }

    if (!_initialLocation) {
        MKCoordinateRegion region;
        region.center = _userLocationAnnotation.coordinate;
        region.span = MKCoordinateSpanMake(0.0005, 0.0005);
        region = [_mapView regionThatFits:region];
        [_mapView setRegion:region animated:YES];
        _initialLocation = lastReportedLocation;
    }
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!_initialLocation) {
        _initialLocation = userLocation.location;

        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        region.span = MKCoordinateSpanMake(0.015, 0.015);

        region = [mapView regionThatFits:region];
        [mapView setRegion:region animated:YES];
    }
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay{
    if([overlay isKindOfClass:[MKPolygon class]]){
        MKPolygonView *view = [[MKPolygonView alloc] initWithOverlay:overlay];
        view.lineWidth = 1;
        view.strokeColor = [UIColor blueColor];
        view.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        return view;
    }
    return nil;
}

@end
