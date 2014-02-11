//
//  TSJavelinAPIClient.h
//  Javelin
//
//  Created by Ben Boyd on 11/5/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "TSJavelinAlertManager.h"
#import "TSJavelinS3UploadManager.h"
#import "TSJavelinAPIChatMessage.h"
#import "TSJavelinAPIAgency.h"
#import "TSJavelinAPIUser.h"

@class TSJavelinAPIUser;
@class TSJavelinAPIAlert;
@class TSJavelinAPIAuthenticationResult;
@class TSJavelinAlertManager;
@class TSJavelinChatManager;
@class TSJavelinPushNotificationManager;
@class TSJavelinAPIAgency;
@class TSJavelinAPIUserProfile;

typedef void (^TSJavelinAPIUserBlock)(TSJavelinAPIUser *user);
typedef void (^TSJavelinAPIVerificationResultBlock)(BOOL checkAgain);
typedef void (^TSJavelinAPIUserProfileUploadBlock)(BOOL profileDataUploadSucceeded, BOOL imageUploadSucceeded);

// Authentication Manager Delegate definition
@protocol TSJavelinAuthenticationManagerDelegate <NSObject>

@optional
- (void)loginSuccessful:(TSJavelinAPIAuthenticationResult *)result;
- (void)loginFailed:(TSJavelinAPIAuthenticationResult *)result;

@end

// Authentication Manager Protocol
@protocol TSJavelinAPIAuthenticationManager <NSObject>

@required

@property (weak) id<TSJavelinAuthenticationManagerDelegate> delegate;

// loggedInUser should be non-nil if a user is logged in
@property (nonatomic, strong) TSJavelinAPIUser *loggedInUser;

// Master API Access Token for non-user-specific actions
@property (nonatomic, strong) NSString *masterAccessToken;

// Init methods
+ (instancetype)initializeSharedManagerWithBaseAuthURL:(NSString *)baseAuthURL;
+ (instancetype)sharedManager;

// User actions
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

- (void)archiveLatestAPNSDeviceToken:(NSData *)deviceToken;
- (NSData *)retrieveLastArchivedAPNSDeviceToken;

- (void)setAPNSDeviceTokenForLoggedInUser:(NSData *)deviceToken;

@end

@interface TSJavelinAPIClient : AFHTTPRequestOperationManager <TSJavelinAlertManagerDelegate>

// The authManager should be used to perform any user-relation actions like
// logging in/out, registration, or setting any user info.
@property (nonatomic, strong) id<TSJavelinAPIAuthenticationManager> authenticationManager;

@property (nonatomic, strong) TSJavelinAlertManager *alertManager;
@property (nonatomic, strong) TSJavelinChatManager *chatManager;
@property (nonatomic, strong) TSJavelinPushNotificationManager *pushNotificationManager;
@property (nonatomic, strong) TSJavelinS3UploadManager *uploadManager;
@property (nonatomic, strong) TSJavelinAPIUserProfileUploadBlock profileUploadBlock;
@property (nonatomic, strong) NSTimer *locationPostTimer;
@property (nonatomic, strong) CLLocation *previouslyPostedLocation;
@property (nonatomic) bool isStillActiveAlert;

// Init methods
+ (instancetype)initializeSharedClientWithBaseURL:(NSString *)baseURL andBaseAuthURL:(NSString *)baseAuthURL;
+ (instancetype)initializeSharedClientWithBaseURL:(NSString *)baseURL;
+ (instancetype)sharedClient;

// Agency actions
- (void)getAgencies:(void (^)(NSArray *agencies))completion;
- (void)getAgencyForLoggedInUser:(void (^)(TSJavelinAPIAgency *agency))completion;

// Mass Alert actions
- (void)getMassAlerts:(void (^)(NSArray *massAlerts))completion;
- (void)receivedNotificationOfNewMassAlert:(NSDictionary *)notification;

// Alert actions
// Valid alert types are 'C' (Chat), 'E' (Emergency), and 'T' (Timer)
- (void)sendEmergencyAlertWithAlertType:(NSString *)type existingLocation:(CLLocation *)location completion:(void (^)(BOOL success))completion;
- (void)findActiveAlertForLoggedinUser:(TSJavelinAlertManagerAlertQueuedBlock)completion;
- (void)cancelAlert;
- (void)findActiveAlertAndCancel;
- (void)alertReceiptReceivedForAlertWithURL:(NSString *)url;

// Message actions
- (void)sendChatMessageForActiveAlert:(TSJavelinAPIChatMessage *)chatMessage completion:(void (^)(TSJavelinAPIChatMessage *sentChatMessage))completion;
- (void)getChatMessagesForActiveAlert:(void (^)(NSArray *chatMessages))completion;
- (void)getChatMessagesForActiveAlertSinceTime:(NSDate *)dateTime completion:(void (^)(NSArray *chatMessages))completion;
- (void)receivedNotificationOfNewChatMessageAvailableForActiveAlert:(NSDictionary *)notification;

// User Profile Upload
- (void)uploadUserProfileData:(TSJavelinAPIUserProfileUploadBlock)completion;

// Twilio Voip
- (void)getTwilioCallToken:(void (^)(NSString *callToken))completion;

@end
