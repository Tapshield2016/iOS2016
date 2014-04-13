//
//  TSHomeViewController.h
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMapView.h"
#import "TSUserLocationButton.h"
#import "TSNavigationViewController.h"
#import "TSVirtualEntourageManager.h"

@interface TSHomeViewController : TSNavigationViewController <MKMapViewDelegate, TSLocationControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet TSMapView *mapView;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *showUserLocationButton;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *entourageButton;

@property (strong, nonatomic) TSVirtualEntourageManager *entourageManager;
@property (strong, nonatomic) UIBarButtonItem *yankBarButton;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (nonatomic) BOOL isTrackingUser;

- (void)mapAlertModeToggle;

- (IBAction)displayVirtualEntourage:(id)sender;
- (IBAction)sendAlert:(id)sender;
- (IBAction)openChatWindow:(id)sender;
- (IBAction)reportAlert:(id)sender;

- (void)clearEntourageAndResetMap;

@end
