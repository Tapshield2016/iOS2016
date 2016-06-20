//
//  TSAppDelegate.h
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AWSReachability.h"
#import <AVFoundation/AVFoundation.h>

#ifdef DEV
#define kEmergencyNumber @"555"
#elif DEMO
#define kEmergencyNumber @"555"
#elif APP_STORE
#define kEmergencyNumber @"911"
#endif

extern NSString * const TSAppDelegateDidFindConnection;
extern NSString * const TSAppDelegateDidLoseConnection;

@class MSDynamicsDrawerViewController;

@interface TSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSDynamicsDrawerViewController *dynamicsDrawerViewController;
@property (strong, nonatomic) UIView *noConnectionIndicator;

@property (strong, nonatomic) AWSReachability *reachability;
@property (assign, nonatomic) BOOL isConnected;

- (void)drawerCanDragForMenu:(BOOL)enabled;

+ (void)openSettings;

- (void)toggleWidePaneState:(BOOL)open;

- (void)removeAllDrawerAnimations;

- (void)drawerCanDragForContacts:(BOOL)enabled;

- (void)shiftStatusBarToPane:(BOOL)pane;

+ (UIView *)statusBar;

@end
