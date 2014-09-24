//
//  TSUserSessionManager.h
//  TapShield
//
//  Created by Adam Share on 8/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSJavelinAPIClient.h"

@interface TSUserSessionManager : NSObject <UITextFieldDelegate>

+ (instancetype)sharedManager;

@property (nonatomic, readonly) UIViewController *rootViewController;

- (void)userStatusCheck;
- (void)showAgencyPicker;
- (void)checkForUserAgency;
+ (BOOL)shouldShowPhoneVerification;
- (BOOL)didJoinFromSelectedAgency;
- (BOOL)didJoinFromAgencies:(NSArray *)array;
+ (void)showPhoneVerification;
+ (void)showAddSecondaryWithAgency:(TSJavelinAPIAgency *)agency;

- (void)dismissWindow:(void (^)(BOOL finished))completion;

+ (BOOL)phoneNumberWasVerified;

@end
