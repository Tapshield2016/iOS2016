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
#import "TSStatusView.h"
#import "TSBottomMapButton.h"

@interface TSHomeViewController : TSNavigationViewController <MKMapViewDelegate, TSLocationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, ADClusterMapViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) TSReportAnnotationManager *reportManager;
@property (weak, nonatomic) TSMenuViewController *menuViewController;
@property (weak, nonatomic) IBOutlet TSMapView *mapView;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *showUserLocationButton;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *entourageButton;
@property (weak, nonatomic) IBOutlet TSStatusView *statusView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewHeight;
@property (weak, nonatomic) IBOutlet TSBottomMapButton *bottomRighButton;
@property (weak, nonatomic) IBOutlet TSBottomMapButton *helpButton;

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (assign, nonatomic) BOOL isTrackingUser;

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
