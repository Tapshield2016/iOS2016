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
#import "TSPageViewController.h"
#import "TSVirtualEntourageManager.h"


@interface TSHomeViewController : TSNavigationViewController <MKMapViewDelegate, TSLocationControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet TSMapView *mapView;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *showUserLocationButton;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *entourageButton;
@property (weak, nonatomic) IBOutlet UIButton *alertButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;

@property (strong, nonatomic) TSVirtualEntourageManager *entourageManager;

@property (strong, nonatomic) UIBarButtonItem *yankBarButton;

@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic) BOOL isTrackingUser;

- (IBAction)displayVirtualEntourage:(id)sender;
- (IBAction)sendAlert:(id)sender;
- (IBAction)openChatWindow:(id)sender;

- (void)clearEntourageAndResetMap;

@end
