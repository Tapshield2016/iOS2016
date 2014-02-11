//
//  TSJavelinAPIAuthenticationManager.h
//  Javelin
//
//  Created by Ben Boyd on 11/5/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "TSJavelinAPIClient.h"

extern NSString * const kTSJavelinAPIAuthenticationManagerLoginFailureInvalidCredentials;
extern NSString * const kTSJavelinAPIAuthenticationManagerLoginFailureInactiveAccount;
extern NSString * const kTSJavelinAPIAuthenticationManagerLoginFailureUnverifiedEmail;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidLoginSuccessfully;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToLogin;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToCreateConnectionToAuthURL;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidRegisterUserNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidVerifyUserNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToVerifyUserNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidLogInUserNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToLogInUserNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidArchiveNewAPNSTokenNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidRetrieveAPITokenNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToRetrieveAPITokenNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidResendVerificationEmailNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToResendVerificationEmailNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToSendVerificationPhoneNumberNotification;
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserAlreadyExistsNotification;

@class TSJavelinAPIUser;

@interface TSJavelinAPIAuthenticationManager : AFHTTPRequestOperationManager <TSJavelinAPIAuthenticationManager, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak) id<TSJavelinAuthenticationManagerDelegate> delegate;
@property (nonatomic, strong) TSJavelinAPIUser *loggedInUser;
@property (nonatomic, strong) NSString *masterAccessToken;

+ (instancetype)initializeSharedManagerWithBaseAuthURL:(NSString *)baseAuthURL;
+ (instancetype)sharedManager;

- (void)registerUserWithAgencyID:(NSUInteger)agencyID
                    emailAddress:(NSString *)emailAddress
                        password:(NSString *)password
                     phoneNumber:(NSString *)phoneNumber
                      disarmCode:(NSString *)disarmCode
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                      completion:(TSJavelinAPIUserBlock)completion;

- (void)logInUser:(NSString *)emailAddress password:(NSString *)password completion:(TSJavelinAPIUserBlock)completion;
- (void)logoutUser:(void (^)(BOOL success))completion;

- (void)isUserLoggedIn:(TSJavelinAPIUserBlock)completion;
- (void)isLoggedInUserEmailVerified:(void (^)(BOOL success))completion;
- (void)isPhoneNumberVerified:(NSString *)phoneNumber completion:(void (^)(BOOL verified))completion;
- (void)resendVerificationEmailForEmailAddress:(NSString *)email completion:(void (^)(BOOL success))completion;
- (void)updateLoggedInUser:(TSJavelinAPIUserBlock)completion;
- (void)updateLoggedInUserDisarmCode:(TSJavelinAPIUserBlock)completion;
- (void)archiveLoggedInUser;

- (NSString *)masterAccessTokenAuthorizationHeader;
- (NSString *)loggedInUserTokenAuthorizationHeader;

- (void)retrieveAPITokenForLoggedInUser:(void (^)(NSString *token))completion;
- (void)sendPasswordResetEmail:(NSString *)emailAddress;

// Push notification methods
- (void)archiveLatestAPNSDeviceToken:(NSData *)deviceToken;
- (NSData *)retrieveLastArchivedAPNSDeviceToken;
- (void)setAPNSDeviceTokenForLoggedInUser:(NSData *)deviceToken;

@end
