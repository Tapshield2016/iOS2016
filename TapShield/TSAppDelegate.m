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
#import <TestFlightSDK/TestFlight.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "TSVirtualEntourageManager.h"
#import "TSLocationController.h"

static NSString * const TSJavelinAPIDevelopmentBaseURL = @"https://dev.tapshield.com/api/v1/";
static NSString * const TSJavelinAPIDemoBaseURL = @"https://demo.tapshield.com/api/v1/";
static NSString * const TSJavelinAPIProductionBaseURL = @"https://api.tapshield.com/api/v1/";

@interface TSAppDelegate () <MSDynamicsDrawerViewControllerDelegate>

@property (nonatomic, strong) UIImageView *windowBackground;
@property (strong, nonatomic) AFNetworkReachabilityManager *manager;

@end

@implementation TSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#ifdef DEV
    [TSJavelinAPIClient initializeSharedClientWithBaseURL:TSJavelinAPIDevelopmentBaseURL];
    NSString *remoteHostName = @"dev.tapshield.com";
    [TestFlight takeOff:@"6bad24cf-5b30-4d46-b045-94d798b7eb37"];
    
#elif DEMO
    [TestFlight takeOff:@"6bad24cf-5b30-4d46-b045-94d798b7eb37"];
    
    [TSJavelinAPIClient initializeSharedClientWithBaseURL:TSJavelinAPIDemoBaseURL];
    NSString *remoteHostName = @"demo.tapshield.com";
    
#elif APP_STORE
    [TSJavelinAPIClient initializeSharedClientWithBaseURL:TSJavelinAPIProductionBaseURL];
    NSString *remoteHostName = @"api.tapshield.com";
#endif
    
    
    _manager = [AFNetworkReachabilityManager managerForDomain:remoteHostName];
                
    [_manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"%@", AFStringFromNetworkReachabilityStatus(status));
        
        switch (status) {
                
            case AFNetworkReachabilityStatusNotReachable:
                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                
                break;
            case AFNetworkReachabilityStatusUnknown:
                
                break;
            default:
                
                break;
        }
    }];
    [_manager startMonitoring];
    
    
//    [TSSocialAccountsManager initializeShareSocialAccountsManager];
    [TSYankManager sharedYankManager];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [UINavigationBar appearance].tintColor = [TSColorPalette tapshieldBlue];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontRalewayMedium size:17.0f] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.3] , NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
    
    [UITableView appearance].separatorInset = UIEdgeInsetsZero;
    [UITableView appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil].separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    [UITableView appearance].tintColor = [TSColorPalette tapshieldBlue];
    [UITableView appearance].separatorColor = [TSColorPalette cellSeparatorColor];
    [UITableView appearance].backgroundColor = [TSColorPalette listBackgroundColor];
//    [UITableView appearance].sectionIndexTrackingBackgroundColor = [TSColorPalette tableViewHeaderColor];
    
    // Override point for customization after application launch.
    self.dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.window.rootViewController;
    self.dynamicsDrawerViewController.delegate = self;
    // Add some styles for the drawer
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerScaleStyler styler], [MSDynamicsDrawerFadeStyler styler], [MSDynamicsDrawerShadowStyler styler]] forDirection:MSDynamicsDrawerDirectionLeft];
    
    [self.dynamicsDrawerViewController setElasticity:0.0f];
    [self.dynamicsDrawerViewController setGravityMagnitude:4.0f];

    TSMenuViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"TSMenuViewController"];
    menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
    
    self.dynamicsDrawerViewController.view.backgroundColor = [UIColor clearColor];
    self.windowBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"side_menu_bg"]];
    self.windowBackground.frame = self.window.bounds;

    // Transition to the first view controller
    [menuViewController transitionToViewController:@"TSHomeViewController"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.dynamicsDrawerViewController;
    [self.window makeKeyAndVisible];
    [self.window addSubview:self.windowBackground];
    [self.window sendSubviewToBack:self.windowBackground];

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
        [TSVirtualEntourageManager sharedManager].isEnabled) {
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"BackgroundTaskExpirationHandler");
            [[TSLocationController sharedLocationController] startStandardLocationUpdates:nil];
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
    NSString *name = @"Notification Center";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        name = @"Notifications";
    }
    NSString *message = [NSString stringWithFormat:@"Push Notifications are used during real-time chat and to recieve Mass Alerts from your agency. \n \n Go to Settings->%@->TapShield  to turn TapShield Push Notifications on", name];
    
    UIAlertView *enablePushNotificationsAlert = [[UIAlertView alloc] initWithTitle:@"Push Notifications enhance the functionality of TapShield.\n"
                                                                           message:message
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles: nil];
    [enablePushNotificationsAlert show];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLatestAPNSDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [TSJavelinPushNotificationManager analyzeNotification:userInfo completion:^(BOOL matchFound, NSString *message) {
        if (!matchFound) {
            // Do something else here, we didn't find a match for any action we need to be aware of...
        }
    }];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [TSJavelinPushNotificationManager analyzeNotification:userInfo completion:^(BOOL matchFound, NSString *message) {
        if (!matchFound) {
            // Do something else here, we didn't find a match for any action we need to be aware of...
        }
    }];
}


- (void)drawerCanDragForMenu:(BOOL)enabled; {
    
    [self.dynamicsDrawerViewController setPaneDragRevealEnabled:enabled forDirection:MSDynamicsDrawerDirectionLeft];
}

@end
