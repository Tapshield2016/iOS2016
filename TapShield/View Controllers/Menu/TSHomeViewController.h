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
#import "TSMenuViewController.h"
#import "TSReportAnnotationManager.h"

@interface TSHomeViewController : TSNavigationViewController <MKMapViewDelegate, TSLocationControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UITextFieldDelegate, ADClusterMapViewDelegate>

@property (strong, nonatomic) TSReportAnnotationManager *reportManager;
@property (strong, nonatomic) TSMenuViewController *menuViewController;
@property (weak, nonatomic) IBOutlet TSMapView *mapView;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *showUserLocationButton;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *entourageButton;

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (assign, nonatomic) BOOL isTrackingUser;

//Yank
@property (assign, nonatomic) BOOL shouldSendAlert;

- (void)mapAlertModeToggle;

- (IBAction)displayVirtualEntourage:(id)sender;
- (IBAction)sendAlert:(id)sender;
- (IBAction)openChatWindow:(id)sender;
- (IBAction)reportAlert:(id)sender;


//Entourage
@property (strong, nonatomic) TSVirtualEntourageManager *entourageManager;
@property (strong, nonatomic) NSTimer *clockTimer;

- (void)clearEntourageAndResetMap;
- (void)entourageModeOn;

@end
