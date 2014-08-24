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
#import "TSJavelinAPIEntourageMember.h"
#import "TSJavelinAPISocialCrimeReport.h"
#import "TSJavelinAPIRegion.h"
#import "TSJavelinAPIDispatchCenter.h"
#import "NSNull+JSON.h"

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
- (void)loginFailed:(TSJavelinAPIAuthenticationResult *)result error:(NSError *)error;

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

- (void)logoutSocial;
- (void)createFacebookUser:(NSString *)facebookAPIAuthToken completion:(void(^)(BOOL finished))completion;
- (void)createTwitterUser:(NSString *)twitterOauthToken secretToken:(NSString *)twitterOauthTokenSecret completion:(void(^)(BOOL finished))completion;
- (void)createGoogleUser:(NSString *)googleAccessToken refreshToken:(NSString *)googleRefreshToken completion:(void(^)(BOOL finished))completion;
- (void)createLinkedInUser:(NSString *)linkedInAccessToken completion:(void(^)(BOOL finished))completion;

// User actions
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

- (void)addSecondaryEmail:(NSString *)email completion:(void(^)(BOOL success, NSString *errorMessage))completion;
- (void)makeSecondaryEmailPrimary:(NSString *)email completion:(void(^)(BOOL success, NSString *errorMessage))completion;
- (void)isSecondaryEmailVerified:(NSString *)email completion:(void(^)(BOOL verified, NSString *errorMessage))completion;
- (void)resendSecondaryEmailActivation:(NSString *)email completion:(void(^)(BOOL success, NSString *errorMessage))completion;
- (void)removeSecondaryEmail:(NSString *)email completion:(void(^)(BOOL success, NSString *errorMessage))completion;

- (NSString *)getPasswordForEmailAddress:(NSString *)emailAddress;
- (void)setRegistrationRecoveryEmail:(NSString *)email Password:(NSString *)password;

- (NSString *)masterAccessTokenAuthorizationHeader;
- (NSString *)loggedInUserTokenAuthorizationHeader;

- (void)retrieveAPITokenForLoggedInUser:(void (^)(NSString *token))completion;
- (void)sendPasswordResetEmail:(NSString *)emailAddress completion:(void(^)(BOOL sent))completion;

- (void)archiveLatestAPNSDeviceToken:(NSData *)deviceToken;
- (NSData *)retrieveLastArchivedAPNSDeviceToken;

- (void)setAPNSDeviceTokenForLoggedInUser:(NSData *)deviceToken;

@end

extern NSString * const TSJavelinAPIClientDidUpdateAgency;

@interface TSJavelinAPIClient : AFHTTPRequestOperationManager

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
@property (nonatomic, strong) CLLocation *locationAwaitingPost;
@property (nonatomic) bool isStillActiveAlert;

// Init methods
+ (instancetype)initializeSharedClientWithBaseURL:(NSString *)baseURL andBaseAuthURL:(NSString *)baseAuthURL;
+ (instancetype)initializeSharedClientWithBaseURL:(NSString *)baseURL;
+ (instancetype)sharedClient;

//Quick methods
+ (TSJavelinAPIUser *)loggedInUser;
+ (TSJavelinAPIAgency *)userAgency;

// Agency actions
- (void)getAgencies:(void (^)(NSArray *agencies))completion;
- (void)getAgenciesNearby:(CLLocation *)currentLocation radius:(float)radius completion:(void (^)(NSArray *agencies))completion;
- (void)getAgencyForLoggedInUser:(void (^)(TSJavelinAPIAgency *agency))completion;
- (void)getUserAgencyForUrl:(NSString *)agencyUrl completion:(void (^)(TSJavelinAPIAgency *agency))completion;

// Mass Alert actions
- (void)getMassAlerts:(void (^)(NSArray *massAlerts))completion;
- (void)receivedNotificationOfNewMassAlert:(NSDictionary *)notification;

// Alert actions
// Valid alert types are 'C' (Chat), 'E' (Emergency), and 'T' (Timer)
- (void)sendEmergencyAlertWithAlertType:(NSString *)type location:(CLLocation *)location completion:(void (^)(BOOL sent, BOOL inside))completion;
- (void)findActiveAlertForLoggedinUser:(void (^)(TSJavelinAPIAlert *activeAlert))completion;
- (void)cancelAlert;
- (void)disarmAlert;
- (void)findActiveAlertAndCancel;
- (void)alertReceiptReceivedForAlertWithURL:(NSString *)url;
- (void)locationUpdated:(CLLocation *)location;

// Message actions
- (void)startChatForActiveAlert;
- (void)clearChatMessages;
- (void)sendChatMessage:(NSString *)message;
- (void)sendChatMessageForActiveAlert:(TSJavelinAPIChatMessage *)chatMessage completion:(void (^)(ChatMessageStatus status))completion;
- (void)getChatMessagesForActiveAlert:(void (^)(NSArray *chatMessages))completion;
- (void)getChatMessagesForActiveAlertSinceTime:(NSDate *)dateTime completion:(void (^)(NSArray *chatMessages))completion;
- (void)receivedNotificationOfNewChatMessageAvailableForActiveAlert:(NSDictionary *)notification;

// User Profile Upload
- (void)uploadUserProfileData:(TSJavelinAPIUserProfileUploadBlock)completion;

// Twilio Voip
- (void)getTwilioCallToken:(void (^)(NSString *callToken))completion;

//Entourage
- (void)addEntourageMember:(TSJavelinAPIEntourageMember *)member completion:(void (^)(id responseObject, NSError *error))completion;
- (void)removeEntourageMember:(TSJavelinAPIEntourageMember *)member completion:(void (^)(id responseObject, NSError *error))completion;
- (void)notifyEntourageMembers:(NSString *)message completion:(void (^)(id responseObject, NSError *error))completion;

//Report
- (void)getSocialCrimeReports:(CLLocation *)location radius:(float)radius since:(NSDate *)date completion:(void (^)(NSArray *reports))completion;
- (void)postSocialCrimeReport:(TSJavelinAPISocialCrimeReport *)report completion:(void (^)(TSJavelinAPISocialCrimeReport *report))completion;
- (void)removeUrl:(NSString *)url completion:(void(^)(BOOL finished))completion;

- (BOOL)shouldRetry:(NSError *)error;
+ (void)registerForUserAgencyUpdatesNotification:(id)object action:(SEL)selector;

@end
