//
//  TSRoutePickerViewController.h
//  TapShield
//
//  Created by Adam Share on 3/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSHomeViewController.h"
#import <MapKit/MapKit.h>

@interface TSRoutePickerViewController : TSNavigationViewController

@property (nonatomic, strong) IBOutlet UISegmentedControl *directionsTypeSegmentedControl;
@property (nonatomic, assign) MKDirectionsTransportType directionsTransportType;

@end
