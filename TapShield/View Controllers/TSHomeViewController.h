//
//  TSHomeViewController.h
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMapView.h"
#import "TSUserLocationButton.h"
#import "TSBaseViewController.h"

@interface TSHomeViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet TSMapView *mapView;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *showUserLocationButton;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end
