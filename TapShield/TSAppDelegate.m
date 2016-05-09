//
//  TSAppDelegate.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAppDelegate.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinPushNotificationManager.h"
#import "MSDynamicsDrawerViewController.h"
#import "MSDynamicsDrawerStyler.h"
#import "TSMenuViewController.h"
#import "TSSocialAccountsManager.h"
#import "TSYankManager.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "TSEntourageSessionManager.h"
#import "TSLocationController.h"
#import "TSAlertManager.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "TSNoNetworkWindow.h"
#import "TSUserSessionManager.h"
#import "TSEntourageContactsViewController.h"
#import "TSAnimatedBackgroundView.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/SignIn.h>
#import <AWSCore/AWSCore.h>

@import CoreTelephony;

static NSString * const TSJavelinAPIDevelopmentBaseURL = @"https://dev.tapshield.com/api/v1/";
static NSString * const TSJavelinAPIDemoBaseURL = @"https://demo.tapshield.com/api/v1/";
static NSString * const TSJavelinAPIProductionBaseURL = @"https://api.tapshield.com/api/v1/";

NSString * const TSAppDelegateDidFindConnection = @"TSAppDelegateDidFindConnection";
NSString * const TSAppDelegateDidLoseConnection = @"TSAppDelegateDidLoseConnection";

@interface TSAppDelegate () <MSDynamicsDrawerViewControllerDelegate>

@property (nonatomic, strong) TSAnimatedBackgroundView *windowBackground;
@property (nonatomic, strong) TSNoNetworkWindow *noNetworkWindow;
@property (nonatomic, strong) TSPopUpWindow *pushNotificationAlertWindow;
@property (nonatomic, strong) TSEntourageContactsViewController *entourageContactsViewController;
@property (strong, nonatomic) CTCallCenter *callCenter;

@end

@implementation TSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1_oqq0LjTMG"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                         credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    
#ifdef DEV
    [TSJavelinAPIClient initializeSharedClientWithBaseURL:TSJavelinAPIDevelopmentBaseURL];
    NSString *remoteHostName = @"dev.tapshield.com";

    
#elif DEMO
    
    [TSJavelinAPIClient initializeSharedClientWithBaseURL:TSJavelinAPIDemoBaseURL];
    NSString *remoteHostName = @"demo.tapshield.com";
    
#elif APP_STORE
    [TSJavelinAPIClient initializeSharedClientWithBaseURL:TSJavelinAPIProductionBaseURL];
    NSString *remoteHostName = @"api.tapshield.com";
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 120;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-40278373-3"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"App Launch"];
    
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
#endif
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] getLoggedInUser:^(TSJavelinAPIUser *user) {
       [[TSEntourageSessionManager sharedManager] resumePreviousEntourage];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kAWSReachabilityChangedNotification
                                               object:nil];
    
    _reachability = [AWSReachability reachabilityWithHostname:remoteHostName];
    [_reachability startNotifier];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil]];
    
    [TSYankManager sharedYankManager];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[TSColorPalette tapshieldBlue]];
    
    [UINavigationBar appearance].tintColor = [TSColorPalette tapshieldBlue];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.3] , NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
    
//    [UITableView appearance].separatorInset = UIEdgeInsetsZero;
//    [UITableView appearance].layoutMargins = UIEdgeInsetsZero;
    [UITableView appearance].tintColor = [TSColorPalette tapshieldBlue];
    [UITableView appearance].separatorColor = [TSColorPalette cellSeparatorColor];
    [UITableView appearance].backgroundColor = [TSColorPalette listBackgroundColor];
    [UITableViewCell appearance].backgroundColor = [TSColorPalette cellBackgroundColor];
//    [UITableViewCell appearance].layoutMargins = UIEdgeInsetsZero;
    
    [UITableViewCell appearanceWhenContainedIn:[UIImagePickerController class], nil].backgroundColor = [TSColorPalette clearColor];
    
//    [UITableViewCell appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], [UIImagePickerController class], nil].separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
//    
//    [UITableView appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], [UIImagePickerController class], nil].layoutMargins = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
//    [UITableView appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], [UIImagePickerController class], nil].separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    
    [UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil].barStyle = UIBarStyleDefault;
    [UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil].tintColor = [TSColorPalette tapshieldBlue];
    [UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
    [[UIBarButtonItem appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.3] , NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
    
    // Override point for customization after application launch.
    self.dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.window.rootViewController;
    self.dynamicsDrawerViewController.delegate = self;
    // Add some styles for the drawer
    
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerShadowStyler styler]] forDirection:MSDynamicsDrawerDirectionLeft];
    
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerShadowStyler styler]] forDirection:MSDynamicsDrawerDirectionRight];
    
    [self.dynamicsDrawerViewController setElasticity:0.0f];
    [self.dynamicsDrawerViewController setGravityMagnitude:8.0f];
    [self.dynamicsDrawerViewController setBounceElasticity:0.0f];
    CGFloat revealWidth = [UIScreen mainScreen].bounds.size.width - 60;
    [self.dynamicsDrawerViewController setRevealWidth:revealWidth forDirection:MSDynamicsDrawerDirectionHorizontal];

    TSMenuViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"TSMenuViewController"];
    menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    
    _entourageContactsViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"TSEntourageContactsViewController"];
    
    [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
    [self.dynamicsDrawerViewController setDrawerViewController:_entourageContactsViewController forDirection:MSDynamicsDrawerDirectionRight];
    
    self.dynamicsDrawerViewController.view.backgroundColor = [UIColor clearColor];

    // Transition to the first view controller
    [menuViewController transitionToViewController:@"TSHomeViewController" animated:NO];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.dynamicsDrawerViewController;
    [self.window makeKeyAndVisible];
    
    self.windowBackground = [[TSAnimatedBackgroundView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:self.windowBackground];
    [self.window sendSubviewToBack:self.windowBackground];
    
    [[TSUserSessionManager sharedManager] userStatusCheck];
    
    [self registerForCallHandler];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([[TSJavelinAPIClient sharedClient] isStillActiveAlert] ||
        [TSYankManager sharedYankManager].isEnabled ||
        [TSEntourageSessionManager sharedManager].isEnabled ||
        [TSAlertManager sharedManager].countdownTimer ||
        [TSAlertManager sharedManager].isAlertInProgress) {
        
        if (![TSAlertManager sharedManager].countdownTimer &&
            ![TSAlertManager sharedManager].isAlertInProgress ) {
            
            if ([TSEntourageSessionManager sharedManager].isEnabled) {
                [[TSLocationController sharedLocationController] cycleGPSSignalStrengthUntilDate:[TSEntourageSessionManager sharedManager].endTimer.fireDate];
            }
            else {
                [[TSLocationController sharedLocationController] enterLowPowerState];
            }
        }
    }
    else {
        [[TSLocationController sharedLocationController] stopLocationUpdates];
        if ([TSJavelinAPIClient loggedInUser] && [[TSJavelinAPIClient loggedInUser] shouldUpdateAlwaysVisibleLocation]) {
            [[TSLocationController sharedLocationController] startSignificantChangeUpdates:nil];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[TSLocationController sharedLocationController] stopMonitoringSignificantLocationChanges];
    
    if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser]) {
        [[TSLocationController sharedLocationController] startStandardLocationUpdates:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


#pragma mark - URL Handler 

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                    annotation:annotation]) {
        return YES;
    }
    
    if ([[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation]) {
        return YES;
    }
    
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    
    if ([[FBSDKApplicationDelegate sharedInstance] application:app
                                                       openURL:url
                                             sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                    annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]) {
        return YES;
    }
    
    if ([[GIDSignIn sharedInstance] handleURL:url
                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]) {
        return YES;
    }
    
    return YES;
}

#pragma mark - Remote Notifications

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"Device token - %@", deviceToken);
    [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLatestAPNSDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [application setApplicationIconBadgeNumber: 0];
    
    [TSJavelinPushNotificationManager analyzeNotification:userInfo completion:^(BOOL matchFound, TSJavelinAPIPushNotification *notification) {
        if (matchFound && notification) {
            // Do something else here, we didn't find a match for any action we need to be aware of...
            [self updateInterfaceWithNotification:notification];
        }
    }];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [TSJavelinPushNotificationManager analyzeNotification:userInfo completion:^(BOOL matchFound, TSJavelinAPIPushNotification *notification) {
        if (matchFound && notification) {
            // Do something else here, we didn't find a match for any action we need to be aware of...
            [self updateInterfaceWithNotification:notification];
            
            if (completionHandler) {
                completionHandler(UIBackgroundFetchResultNewData);
            }
            else {
                [application setApplicationIconBadgeNumber: 0];
            }
        }
        else {
            if (completionHandler) {
                completionHandler(UIBackgroundFetchResultNoData);
            }
            else {
                [application setApplicationIconBadgeNumber: 0];
            }
        }
    }];
}

- (void)updateInterfaceWithNotification:(TSJavelinAPIPushNotification *)notification {
    
    if ((notification.alertType == TSJavelinPushNotificationTypeCrimeReport || notification.alertType == TSJavelinPushNotificationTypeAlertCompletion) && notification.alertBody.length) {
        _pushNotificationAlertWindow = [[TSPopUpWindow alloc] initWithMessage:notification.alertBody tapToDismiss:YES];
        [_pushNotificationAlertWindow show];
    }
}

#pragma mark - Local Notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    
    if (application.applicationState == UIApplicationStateActive) {
        if (notification) {
            [application cancelLocalNotification:notification];
        }
        return;
    }
    
    if ([[notification.userInfo objectForKey:@"destination"] isEqualToString:kAlertOutsideGeofence]) {
        [[TSAlertManager sharedManager] callEmergencyNumber];
    }
    
    if (notification) {
        [application cancelLocalNotification:notification];
    }
}


#pragma mark - Side Drawer

- (void)drawerCanDragForMenu:(BOOL)enabled; {
    
    [self.dynamicsDrawerViewController setPaneDragRevealEnabled:enabled forDirection:MSDynamicsDrawerDirectionLeft];
}

- (void)drawerCanDragForContacts:(BOOL)enabled; {
    
    [self.dynamicsDrawerViewController setPaneDragRevealEnabled:enabled forDirection:MSDynamicsDrawerDirectionRight];
}

#pragma mark - Reachability

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    AWSReachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[AWSReachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(AWSReachability *)reachability {

    if (reachability == _reachability) {
        BOOL reachable;
        AWSNetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        switch (netStatus) {
            case AWSNetworkStatusNotReachable: {
                reachable = NO;
                break;
            }
                
            case AWSNetworkStatusReachableViaWWAN: {
                if (reachability.connectionRequired) {
                    reachable = NO;
                    break;
                }
                reachable = YES;
                break;
            }
                
            case AWSNetworkStatusReachableViaWiFi: {
                if (reachability.connectionRequired) {
                    reachable = NO;
                    break;
                }
                reachable = YES;
                break;
            }
        }
        
        _isConnected = reachable;
        
        if (reachable) {
            if (_noNetworkWindow) {
                [_noNetworkWindow dismiss:^(BOOL finished) {
                    _noNetworkWindow = nil;
                }];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:TSAppDelegateDidFindConnection object:nil];
            NSLog(@"Connected");
        }
        else {
            if (!_noNetworkWindow) {
                _noNetworkWindow = [[TSNoNetworkWindow alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
                [_noNetworkWindow show];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:TSAppDelegateDidLoseConnection object:nil];
            NSLog(@"No Connection");
        }
    }
}

#pragma mark - Settings App

+ (void)openSettings
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url];
}


#pragma mark - Network Calls

- (void)registerForCallHandler {
    
    self.callCenter = [[CTCallCenter alloc] init];
    
    [self.callCenter setCallEventHandler:^(CTCall* call)
     {
         if ([call.callState isEqualToString: CTCallStateConnected]) {
             [[TSAlertManager sharedManager] notifiedCTCallStateConnected:call];
         }
         else if ([call.callState isEqualToString: CTCallStateDialing]) {
             [[TSAlertManager sharedManager] notifiedCTCallStateDialing:call];
         }
         else if ([call.callState isEqualToString: CTCallStateDisconnected]) {
             [[TSAlertManager sharedManager] notifiedCTCallStateDisconnected:call];
             
         } else if ([call.callState isEqualToString: CTCallStateIncoming]) {
             [[TSAlertManager sharedManager] notifiedCTCallStateIncoming:call];
         }
         
     }];
}

- (void)removeAllDrawerAnimations {
    [self.dynamicsDrawerViewController.dynamicAnimator removeAllBehaviors];
}

- (void)toggleWidePaneState:(BOOL)open {
    
    if (self.dynamicsDrawerViewController.paneState == MSDynamicsDrawerPaneStateOpenWide && !open) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionRight];
    }
    else if (open) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpenWide inDirection:MSDynamicsDrawerDirectionRight];
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction {
    
    if (paneState == MSDynamicsDrawerPaneStateOpen) {
        [self.windowBackground animateRoute];
    }
    else if (paneState == MSDynamicsDrawerPaneStateClosed) {
        [self.windowBackground stopRouteAnimation];
        [_entourageContactsViewController.tableViewController clearSearch];
    }
}

- (BOOL)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController shouldBeginPanePan:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    return YES;
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction {
    
    
}

- (void)shiftStatusBarToPane:(BOOL)pane {
    
    UIView *statusBar = [TSAppDelegate statusBar];
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:300.0
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (pane) {
                             statusBar.transform = CGAffineTransformMakeTranslation(self.dynamicsDrawerViewController.paneView.frame.origin.x, self.dynamicsDrawerViewController.paneView.frame.origin.y);
                         }
                         else {
                             statusBar.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                     } completion:^(BOOL finished) {
                         
                     }];
}

+ (UIView *)statusBar {
    
    NSString *key = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9] encoding:NSASCIIStringEncoding];
    id object = [UIApplication sharedApplication];
    UIView *statusBar;
    if ([object respondsToSelector:NSSelectorFromString(key)]) {
        statusBar = [object valueForKey:key];
    }
    return statusBar;
}

@end
