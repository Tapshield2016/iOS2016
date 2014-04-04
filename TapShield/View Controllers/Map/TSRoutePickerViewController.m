//
//  TSRoutePickerViewController.m
//  TapShield
//
//  Created by Adam Share on 3/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRoutePickerViewController.h"

@interface TSRoutePickerViewController ()

@property (nonatomic, strong) MKDirections *directions;

@end

@implementation TSRoutePickerViewController

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
    
    _hitTestView.sendToView = _homeViewController.view;
    
    _directionsTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Car", @"Walk"]];
    _directionsTypeSegmentedControl.tintColor = [TSColorPalette tapshieldBlue];
    [_directionsTypeSegmentedControl setSelectedSegmentIndex:0];
    
    _directionsTransportType = MKDirectionsTransportTypeAutomobile;
    [_directionsTypeSegmentedControl addTarget:self
                                        action:@selector(transportTypeSegmentedControlValueChanged:)
                              forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setTitleView:_directionsTypeSegmentedControl];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [_homeViewController.entourageManager userSelectedDestination:_destinationMapItem forTransportType:_directionsTransportType];
    
    // Display user location and selected destination if present
    if (_homeViewController.entourageManager.destinationMapItem) {
        _homeViewController.isTrackingUser = NO;
        [self requestAndDisplayRoutesForSelectedDestination];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UISegmentedControl event handlers

- (void)transportTypeSegmentedControlValueChanged:(id)sender {
    switch ([_directionsTypeSegmentedControl selectedSegmentIndex]) {
            
        case 0:
            _directionsTransportType = MKDirectionsTransportTypeAutomobile;
            break;
            
        case 1:
            _directionsTransportType = MKDirectionsTransportTypeWalking;
            break;
            
        default:
            _directionsTransportType = MKDirectionsTransportTypeAny;
            break;
    }
    
    [_homeViewController.entourageManager userSelectedDestination:_destinationMapItem forTransportType:_directionsTransportType];
    [self requestAndDisplayRoutesForSelectedDestination];
}




#pragma mark - Route management and display methods

- (void)calculateETAForSelectedDestination:(void (^)(NSTimeInterval expectedTravelTime))completion {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:_homeViewController.entourageManager.destinationMapItem];
    [request setTransportType:_homeViewController.entourageManager.destinationTransportType];
    [request setRequestsAlternateRoutes:YES];
    
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
            if ((error.code == MKErrorPlacemarkNotFound || error.code == MKErrorDirectionsNotFound) && _homeViewController.entourageManager.destinationTransportType == MKDirectionsTransportTypeWalking) {
                NSLog(@"Error with walking directions, trying again with 'Any'");
                _homeViewController.entourageManager.destinationTransportType = MKDirectionsTransportTypeAny;
                [self calculateETAForSelectedDestination:completion];
            }
        }
    }];
}

- (void)requestAndDisplayRoutesForSelectedDestination {
    
    if (!_homeViewController.mapView.userLocationAnnotation || !_homeViewController.entourageManager.destinationAnnotation) {
        return;
    }
    
    [_homeViewController.mapView showAnnotations:@[_homeViewController.mapView.userLocationAnnotation, _homeViewController.entourageManager.destinationAnnotation] animated:YES];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:_homeViewController.entourageManager.destinationMapItem];
    [request setTransportType:_homeViewController.entourageManager.destinationTransportType]; // This can be limited to automobile and walking directions.
    [request setRequestsAlternateRoutes:YES]; // Gives you several route options.
    
    if (_directions.isCalculating) {
        [_directions cancel];
    }
    
    _homeViewController.entourageManager.selectedRoute = nil;
    [_homeViewController.entourageManager removeRouteOverlaysAndAnnotations];
    
    _directions = [[MKDirections alloc] initWithRequest:request];
    [_directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            _homeViewController.entourageManager.routes = [response routes];
            [_homeViewController.entourageManager addRouteOverlaysToMapViewAndAnnotations];
            [_homeViewController.mapView showAnnotations:_homeViewController.entourageManager.routingAnnotations animated:YES];
        }
    }];
}









@end
