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
extern NSString * const kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserRequiresDomain;

@class TSJavelinAPIUser;

@interface TSJavelinAPIAuthenticationManager : AFHTTPRequestOperationManager <TSJavelinAPIAuthenticationManager, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak) id<TSJavelinAuthenticationManagerDelegate> delegate;
@property (nonatomic, strong) TSJavelinAPIUser *loggedInUser;
@property (nonatomic, strong) NSString *masterAccessToken;

+ (instancetype)initializeSharedManagerWithBaseAuthURL:(NSString *)baseAuthURL;
+ (instancetype)sharedManager;

- (void)logoutSocial;
- (void)createFacebookUser:(NSString *)facebookAPIAuthToken;
- (void)createTwitterUser:(NSString *)twitterOauthToken secretToken:(NSString *)twitterOauthTokenSecret;
- (void)createGoogleUser:(NSString *)googleAccessToken refreshToken:(NSString *)googleRefreshToken;
- (void)createLinkedInUser:(NSString *)linkedInAccessToken;

- (void)registerUser:(TSJavelinAPIUser *)user
          completion:(void (^)(id responseObject))completion;

- (void)logInUser:(NSString *)emailAddress password:(NSString *)password completion:(TSJavelinAPIUserBlock)completion;
- (void)logoutUser:(void (^)(BOOL success))completion;

- (void)isUserLoggedIn:(TSJavelinAPIUserBlock)completion;
- (void)isLoggedInUserEmailVerified:(void (^)(BOOL success))completion;
- (void)resendVerificationEmailForEmailAddress:(NSString *)email completion:(void (^)(BOOL success))completion;
- (void)getLoggedInUser:(TSJavelinAPIUserBlock)completion;
- (void)updateLoggedInUser:(TSJavelinAPIUserBlock)completion;
- (void)updateLoggedInUserAgency:(TSJavelinAPIUserBlock)completion;
- (void)updateLoggedInUserDisarmCode:(TSJavelinAPIUserBlock)completion;
- (void)archiveLoggedInUser;
- (void)checkPhoneVerificationCode:(NSString *)codeFromUser completion:(void (^)(id responseObject))completion;
- (void)sendPhoneNumberVerificationRequest:(NSString *)phoneNumber completion:(void (^)(id responseObject))completion;

//secondary email
- (void)addSecondaryEmail:(NSString *)email;

- (NSString *)getPasswordForEmailAddress:(NSString *)emailAddress;
- (void)setRegistrationRecoveryEmail:(NSString *)email Password:(NSString *)password;

- (NSString *)masterAccessTokenAuthorizationHeader;
- (NSString *)loggedInUserTokenAuthorizationHeader;

- (void)retrieveAPITokenForLoggedInUser:(void (^)(NSString *token))completion;
- (void)sendPasswordResetEmail:(NSString *)emailAddress completion:(void(^)(BOOL sent))completion;

// Push notification methods
- (void)archiveLatestAPNSDeviceToken:(NSData *)deviceToken;
- (NSData *)retrieveLastArchivedAPNSDeviceToken;
- (void)setAPNSDeviceTokenForLoggedInUser:(NSData *)deviceToken;

@end
