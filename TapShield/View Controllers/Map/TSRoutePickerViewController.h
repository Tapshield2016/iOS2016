//
//  TSRoutePickerViewController.h
//  TapShield
//
//  Created by Adam Share on 3/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSHomeViewController.h"
#import "TSHitTestForwardingView.h"
#import <MapKit/MapKit.h>

@interface TSRoutePickerViewController : TSNavigationViewController

@property (nonatomic, strong) TSHomeViewController *homeViewController;
@property (nonatomic, strong) MKMapItem *destinationMapItem;
@property (nonatomic, strong) UISegmentedControl *directionsTypeSegmentedControl;
@property (nonatomic, assign) MKDirectionsTransportType directionsTransportType;
@property (weak, nonatomic) IBOutlet UIView *routeInfoView;
@property (weak, nonatomic) IBOutlet TSBaseLabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *etaLabel;
@property (weak, nonatomic) IBOutlet TSHitTestForwardingView *hitTestView;

@end
