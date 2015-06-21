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
#import "TSEntourageSessionManager.h"
#import "TSMenuViewController.h"
#import "TSReportAnnotationManager.h"
#import "TSStatusView.h"
#import "TSBottomMapButton.h"
#import "TSIconBadgeView.h"


extern NSString * const TSMapViewWillChangeRegion;
extern NSString * const TSMapViewDidChangeRegion;

@interface TSHomeViewController : TSNavigationViewController <MKMapViewDelegate, TSLocationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, TSClusterMapViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) TSMenuViewController *menuViewController;
@property (weak, nonatomic) IBOutlet TSMapView *mapView;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *showUserLocationButton;
@property (weak, nonatomic) IBOutlet TSUserLocationButton *yankButton;
@property (weak, nonatomic) IBOutlet TSStatusView *statusView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewHeight;
@property (weak, nonatomic) IBOutlet TSBottomMapButton *routeButton;
@property (weak, nonatomic) IBOutlet TSBottomMapButton *helpButton;
@property (weak, nonatomic) IBOutlet TSBottomMapButton *reportButton;

@property (strong, nonatomic) MKMapItem *userLocationItem;

@property (strong, nonatomic) TSIconBadgeView *badgeView;

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (assign, nonatomic) BOOL isTrackingUser;

- (void)mapAlertModeToggle;

- (IBAction)toggleYank:(id)sender;
- (IBAction)sendAlert:(id)sender;
- (IBAction)openEntourage:(id)sender;
- (IBAction)reportAlert:(id)sender;




//Entourage
@property (strong, nonatomic) TSEntourageSessionManager *entourageManager;

- (void)showTimeAdjustViewController;

- (void)clearEntourageMap;
- (void)entourageModeOn;
- (void)setIsTrackingUser:(BOOL)isTrackingUser animateToUser:(BOOL)animate;
- (void)moveMapViewToCoordinate:(CLLocationCoordinate2D)coordinate spanDelta:(float)delta;

- (IBAction)callEmergencyNumber:(id)sender;
- (IBAction)callAgencyDispatcher:(id)sender;
- (IBAction)openChat:(id)sender;

@end
