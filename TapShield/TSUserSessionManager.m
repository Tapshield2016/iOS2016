//
//  TSUserSessionManager.m
//  TapShield
//
//  Created by Adam Share on 8/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserSessionManager.h"
#import "TSJavelinAPIClient.h"
#import "TSLocationController.h"
#import "NSDate+Utilities.h"

static NSString * const TSUserSessionManagerDeclinedAgency = @"TSUserSessionManagerDeclinedAgency";

@interface TSUserSessionManager ()

@property (strong, nonatomic) UIWindow *window;

@end

@implementation TSUserSessionManager

static TSUserSessionManager *_sharedManagerInstance = nil;
static dispatch_once_t predicate;


+ (instancetype)sharedManager {
    
    if (_sharedManagerInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedManagerInstance = [[self alloc] init];
        });
    }
    
    return _sharedManagerInstance;
}

- (void)checkForUserAgency {
    
    TSJavelinAPIUser *user = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser];
    BOOL userDeclined = [[NSUserDefaults standardUserDefaults] boolForKey:TSUserSessionManagerDeclinedAgency];
    
    if (!user || user.agency || userDeclined) {
        return;
    }
    
    [[TSLocationController sharedLocationController] startStandardLocationUpdates:^(CLLocation *location) {
        [[TSJavelinAPIClient sharedClient] getAgenciesNearby:location radius:10.0 completion:^(NSArray *agencies) {
            
            if (!agencies || !agencies.count) {
                return;
            }
            
            if ([self didJoinAgency:agencies]) {
                return;
            }
            
            if ([self shouldAskToJoinAgencies]) {
                [self askToJoinAgencies:agencies];
            }
        }];
    }];
}

- (BOOL)didJoinAgency:(NSArray *)array {
    
    TSJavelinAPIUser *user = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser];
    for (TSJavelinAPIAgency *agency in array) {
        if ([user isAvailableForDomain:agency.domain]) {
            user.agency = agency;
            [[[TSJavelinAPIClient sharedClient] authenticationManager] updateLoggedInUserAgency:nil];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)shouldAskToJoinAgencies {
    
    return YES;
}

- (void)askToJoinAgencies:(NSArray *)agencies {
    
    if (agencies.count > 1) {
        [self showAgencyPicker:agencies];
    }
    else if (agencies.count == 1) {
        [self singleAgencyChoice:agencies[0]];
    }
}

- (void)showAgencyPicker:(NSArray *)agencies {
    
    
}

- (void)singleAgencyChoice:(TSJavelinAPIAgency *)agency {
    
}

#pragma mark UIWindow

- (void)showWindowWithRootViewController:(UIViewController *)viewController {
    
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = [UIColor clearColor];
    }
    
    if (viewController) {
        _window.rootViewController = viewController;
    }
    
    [_window makeKeyAndVisible];
}

- (void)dismissWindow:(void (^)(BOOL finished))completion  {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            _window.alpha = 0.0f;
        } completion:^(BOOL finished) {
            
            if (completion) {
                completion(finished);
            }
            
            [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
            _window = nil;
        }];
    });
}

@end
