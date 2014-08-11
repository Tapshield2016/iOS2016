//
//  TSJavelinAPIAuthenticationManager.m
//  Javelin
//
//  Created by Ben Boyd on 11/5/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIAuthenticationManager.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIUser.h"
#import "TSJavelinAPIAgency.h"
#import "TSJavelinAPIAuthenticationResult.h"
#import "SSKeychain.h"

static NSString * const kTSJavelinAPIAuthenticationManagerEncodedLoggedInUserArchiveKey = @"kTSJavelinAPIAuthenticationManagerEncodedLoggedInUserArchiveKey";
static NSString * const kTSJavelinAPIAuthenticationManagerKeyChainServiceName = @"kTSJavelinAPIAuthenticationManagerKeyChainServiceName";
static NSString * const TSJavelinAPIDevelopmentMasterAccessToken = @"35204055c8518dd538f563ee729e70acef71cfeb";
static NSString * const TSJavelinAPIProductionMasterAccessToken = @"bb83910a015cb8a06bc62a723bf63fa969792acd";

NSString * const kTSJavelinAPIAuthenticationManagerLoginFailureInvalidCredentials = @"kTSJavelinAPIAuthenticationManagerLoginFailureInvalidCredentials";
NSString * const kTSJavelinAPIAuthenticationManagerLoginFailureInactiveAccount = @"kTSJavelinAPIAuthenticationManagerLoginFailureInactiveAccount";
NSString * const kTSJavelinAPIAuthenticationManagerLoginFailureUnverifiedEmail = @"kTSJavelinAPIAuthenticationManagerLoginFailureUnverifiedEmail";
NSString * const kTSJavelinAPIAuthenticationManagerLoginFailureServerError = @"kTSJavelinAPIAuthenticationManagerLoginFailureServerError";
NSString * const kTSJavelinAPIAuthenticationManagerLoginFailureUnknownError = @"kTSJavelinAPIAuthenticationManagerLoginFailureUnknownError";

static NSString *const kTSJavelinAPIAuthenticationManagerAPNSTokenArchiveKey = @"kTSJavelinAPIAuthenticationManagerAPNSTokenArchiveKey";

// Notifications
NSString * const kTSJavelinAPIAuthenticationManagerDidLoginSuccessfully = @"kTSJavelinAPIAuthenticationManagerDidLoginSuccessfully";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToLogin = @"kTSJavelinAPIAuthenticationManagerDidFailToLogin";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToCreateConnectionToAuthURL = @"kTSJavelinAPIAuthenticationManagerDidFailToCreateConnectionToAuthURL";
NSString * const kTSJavelinAPIAuthenticationManagerDidRegisterUserNotification = @"kTSJavelinAPIAuthenticationManagerDidRegisterUserNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserNotification = @"kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidVerifyUserNotification = @"kTSJavelinAPIAuthenticationManagerDidVerifyUserNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToVerifyUserNotification = @"kTSJavelinAPIAuthenticationManagerDidFailToVerifyUserNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidLogInUserNotification = @"kTSJavelinAPIAuthenticationManagerDidLogInUserNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToLogInUserNotification = @"kTSJavelinAPIAuthenticationManagerDidFailToLogInUserNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidArchiveNewAPNSTokenNotification = @"kTSJavelinAPIAuthenticationManagerDidArchiveNewAPNSTokenNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidRetrieveAPITokenNotification = @"kTSJavelinAPIAuthenticationManagerDidRetrieveAPITokenNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToRetrieveAPITokenNotification = @"kTSJavelinAPIAuthenticationManagerDidFailToRetrieveAPITokenNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidResendVerificationEmailNotification = @"kTSJavelinAPIAuthenticationManagerDidResendVerificationEmailNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToResendVerificationEmailNotification = @"kTSJavelinAPIAuthenticationManagerDidFailToResendVerificationEmailNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToSendVerificationPhoneNumberNotification = @"kTSJavelinAPIAuthenticationManagerDidFailToResendVerificationEmailNotification";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserAlreadyExistsNotification = @"User with this Email address already exists.";
NSString * const kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserRequiresDomain = @"kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserRequiresDomain";

@interface TSJavelinAPIAuthenticationManager ()

@property (nonatomic, strong) NSData *requestBodyData;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) TSJavelinAPIUserBlock loginCompletionBlock;
@property (nonatomic, strong) TSJavelinAPIVerificationResultBlock verificationCompletionBlock;

@end

@implementation TSJavelinAPIAuthenticationManager {
    // Including here for proper override of getter/setter
    TSJavelinAPIUser *_loggedInUser;
}

@synthesize delegate = _delegate; // Synthesizing manually because it's from protocol definition

static TSJavelinAPIAuthenticationManager *_sharedAuthManager;
static dispatch_once_t onceToken;

+ (instancetype)initializeSharedManagerWithBaseAuthURL:(NSString *)baseAuthURL {
    if (!_sharedAuthManager) {
        dispatch_once(&onceToken, ^{
            _sharedAuthManager = [[TSJavelinAPIAuthenticationManager alloc] initWithURL:baseAuthURL];
        });

        // Prime the archived user
        _sharedAuthManager.loggedInUser = [_sharedAuthManager retrieveArchivedLoggedInUser];

#ifdef DEV
        _sharedAuthManager.masterAccessToken = TSJavelinAPIDevelopmentMasterAccessToken;
#elif DEMO
        _sharedAuthManager.masterAccessToken = TSJavelinAPIDevelopmentMasterAccessToken;
#elif APP_STORE
        _sharedAuthManager.masterAccessToken = TSJavelinAPIProductionMasterAccessToken;
#endif
    }

    return _sharedAuthManager;
}

+ (instancetype)sharedManager {
    if (_sharedAuthManager == nil) {
        [NSException raise:@"Shared Manager Not Initialized"
                    format:@"Before calling [TSJavelinAPIAuthenticationManager sharedManager] you must first initialize the shared client"];
    }

    return _sharedAuthManager;
}

- (id)initWithURL:(NSString *)loginURL {
    self = [super initWithBaseURL:[NSURL URLWithString:loginURL]];
    if (!self) {
        return nil;
    }

    _responseData = [[NSMutableData alloc] initWithCapacity:512];

    return self;
}




#pragma mark - Social Authentication Methods

- (void)socialLoggedInUserWithAttributes:(NSDictionary *)attributes {
    
    if (_loggedInUser) {
        return;
    }
    
    [self setLoggedInUser:[[TSJavelinAPIUser alloc] initWithAttributes:attributes]];
    
    if ([_delegate respondsToSelector:@selector(loginSuccessful:)]) {
        [_delegate loginSuccessful:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidLoginSuccessfully object:nil];
    [self storeUserCredentials:_emailAddress password:_password];
    _emailAddress = nil;
    _password = nil;
    
    [self deleteCookiesForLoginDomain];
    
    [self retrieveAPITokenForLoggedInUser:^(NSString *token) {
        if (token) {
            [[TSJavelinAPIClient sharedClient] getAgencyForLoggedInUser:nil];
            
        }
        else {
            NSLog(@"Social Loggin failed to retrieve token");
        }
    }];
}


- (void)socialLoginFailed {
    
    if ([_delegate respondsToSelector:@selector(loginFailed:error:)]) {
        [_delegate loginFailed:nil error:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToLogin object:nil];
}

- (void)logoutSocial {
    [self GET:@"logout/"
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"Success: %@", responseObject);
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"ERROR: %@", error);
      }];
}

- (void)createFacebookUser:(NSString *)facebookAPIAuthToken {
    [self.requestSerializer setValue:[self masterAccessTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/create-facebook-user/"
    parameters:@{ @"access_token": facebookAPIAuthToken }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           
           [self socialLoggedInUserWithAttributes:responseObject];
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"%@", error);
           [self socialLoginFailed];
       }];
}

- (void)createTwitterUser:(NSString *)twitterOauthToken secretToken:(NSString *)twitterOauthTokenSecret {
    [self.requestSerializer setValue:[self masterAccessTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/create-twitter-user/"
    parameters:@{ @"oauth_token": twitterOauthToken,
                  @"oauth_token_secret": twitterOauthTokenSecret }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           
           [self socialLoggedInUserWithAttributes:responseObject];
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"%@", error);
           [self socialLoginFailed];
       }];
}

- (void)createGoogleUser:(NSString *)googleAccessToken refreshToken:(NSString *)googleRefreshToken {
    [self.requestSerializer setValue:[self masterAccessTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/create-google-user/"
    parameters:@{ @"access_token": googleAccessToken,
                  @"refresh_token": googleRefreshToken }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           
           [self socialLoggedInUserWithAttributes:responseObject];
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"%@", error);
           [self socialLoginFailed];
       }];
}

- (void)createLinkedInUser:(NSString *)linkedInAccessToken {
    [self.requestSerializer setValue:[self masterAccessTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/create-linkedin-user/"
    parameters:@{ @"access_token": linkedInAccessToken }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           
           [self socialLoggedInUserWithAttributes:responseObject];
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"%@", error);
           [self socialLoginFailed];
       }];
}


#pragma mark - Login/Registration Methods



- (void)registerUser:(TSJavelinAPIUser *)user
                      completion:(void (^)(id responseObject))completion {
    
    NSDictionary *parameters = [user parametersForRegistration];
    
    if (user.agency.requireDomainEmails) {
        if (![user isAvailableForDomain:user.agency.domain]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserRequiresDomain object:user.agency.domain];
            return;
        }
    }
    
    // Set default Authorization token for allowing access to register API method
    [self.requestSerializer setValue:[self masterAccessTokenAuthorizationHeader]
                           forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/register/"
    parameters:parameters
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           [self storeUserCredentials:user.email password:user.password];
           _emailAddress = user.email;
           _password = user.password;
           
           if (completion) {
               completion(responseObject);
           }
           
           [self.requestSerializer clearAuthorizationHeader];
           [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidRegisterUserNotification
                                                               object:responseObject];
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSLog(@"%@", error);
           
           [self.requestSerializer clearAuthorizationHeader];
           [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToRegisterUserNotification
                                                               object:operation.responseObject];
           if (completion) {
               completion(operation.responseObject);
           }
       }
     ];
}

- (void)logInUser:(NSString *)emailAddress password:(NSString *)password completion:(TSJavelinAPIUserBlock)completion {
    _emailAddress = emailAddress;
    _password = password;

    if (!_emailAddress || !_password) {
        if (completion) {
            completion(nil);
        }
        return;
    }

    if (completion) {
        _loginCompletionBlock = completion;
    }

    [self makeLoginRequest:nil];
}

- (void)logoutUser:(void (^)(BOOL success))completion {
    
    [self removeArchivedLoggedInUser];
    
    _loggedInUser = nil;
    
    if (completion) {
        completion(YES);
    }
}

- (void)isUserLoggedIn:(TSJavelinAPIUserBlock)completion {
    if (_loggedInUser) {
        if (completion) {
            completion(_loggedInUser);
        }
    }
    else {
        if (completion) {
            completion(nil);
        }
    }
}

- (void)getLoggedInUser:(TSJavelinAPIUserBlock)completion {
    
    if (!_loggedInUser) {
        return;
    }
    
    // Set default Authorization token for allowing access to register API method
    [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:_loggedInUser.url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          [_loggedInUser updateWithAttributes:responseObject];
          
          if ([responseObject[@"agency"] isKindOfClass:[NSString class]]) {
              
              [[TSJavelinAPIClient sharedClient] getUserAgencyForUrl:responseObject[@"agency"]
                                                          completion:nil];
          }
          
          if (completion) {
              completion(_loggedInUser);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          
          if ([[TSJavelinAPIClient sharedClient] shouldRetry:error]) {
              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
              dispatch_after(popTime, dispatch_get_main_queue(), ^{
                  [self getLoggedInUser:completion];
              });
          }
          else {
              NSLog(@"%@", error);
              if (completion) {
                  completion(nil);
              }
          }
      }];
}

- (void)isLoggedInUserEmailVerified:(void (^)(BOOL success))completion {
    if (!_loggedInUser && !_emailAddress) {
        if (completion) {
            completion(NO);
        }
        return;
    }

    NSString *userIdentifier;

    if (_loggedInUser) {
        userIdentifier = _loggedInUser.email;
    }
    else {
        userIdentifier = _emailAddress;
    }

    // Set default Authorization token for allowing access to register API method
    [self.requestSerializer setValue:[self masterAccessTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:@"api/verified/"
    parameters:@{@"email": userIdentifier}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           BOOL isVerified = [[responseObject valueForKey:@"message"] boolValue];
           _loggedInUser.isEmailVerified = isVerified;
           [self archiveLoggedInUser];
           [self.requestSerializer clearAuthorizationHeader];
           completion(isVerified);
           [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidVerifyUserNotification
                                                               object:responseObject];
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"%@", error);
           [self.requestSerializer clearAuthorizationHeader];
           [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToVerifyUserNotification
                                                               object:error];
       }
     ];
}

- (void)resendVerificationEmailForEmailAddress:(NSString *)email completion:(void (^)(BOOL success))completion {
    [self.requestSerializer setValue:[self masterAccessTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/resend-verification/"
    parameters:@{ @"email": email }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completion) {
                completion(YES);
            }
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kTSJavelinAPIAuthenticationManagerDidResendVerificationEmailNotification
                              object:responseObject];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completion) {
                completion(NO);
            }
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToResendVerificationEmailNotification
                              object:error];
    }];
}

- (void)updateLoggedInUser:(TSJavelinAPIUserBlock)completion {
    if (!_loggedInUser) {
        return;
    }
    
    NSDictionary *parameters = [_loggedInUser parametersForUpdate];

    [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self PATCH:_loggedInUser.url
     parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"updateLoggedInUser: %@", responseObject);
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR!!!!! updateLoggedInUser: %@", error);
            
            if ([[TSJavelinAPIClient sharedClient] shouldRetry:error]) {
                // Delay execution of my block for 10 seconds.
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^{
                    [self updateLoggedInUser:completion];
                });
            }
            else {
                if (completion) {
                    completion(nil);
                }
            }
    }];
}

- (void)updateLoggedInUserAgency:(TSJavelinAPIUserBlock)completion {
    
    if (!_loggedInUser) {
        return;
    }
    
    if (!_loggedInUser.agency.url) {
        return;
    }
    
    [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self PATCH:_loggedInUser.url
     parameters:@{@"agency": _loggedInUser.agency.url}
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"updateLoggedInUser: %@", responseObject);
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR!!!!! updateLoggedInUser: %@", error);
            
            if ([[TSJavelinAPIClient sharedClient] shouldRetry:error]) {
                // Delay execution of my block for 10 seconds.
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^{
                    [self updateLoggedInUser:completion];
                });
            }
            else {
                if (completion) {
                    completion(nil);
                }
            }
        }];
}

- (void)updateLoggedInUserDisarmCode:(TSJavelinAPIUserBlock)completion {
    if (!_loggedInUser) {
        return;
    }
    
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Token %@", _loggedInUser.apiToken]
                  forHTTPHeaderField:@"Authorization"];
    
    [self PATCH:_loggedInUser.url
     parameters:@{ @"disarm_code": _loggedInUser.disarmCode}
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"updateLoggedInUserDisarmCode: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR!!!!! updateLoggedInUserDisarmCode: %@", error);
            
            if ([[TSJavelinAPIClient sharedClient] shouldRetry:error]) {
                // Delay execution of my block for 10 seconds.
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^{
                    [self updateLoggedInUserDisarmCode:completion];
                });
            }
            else {
                if (completion) {
                    completion(nil);
                }
            }
        }];
}


- (void)sendPasswordResetEmail:(NSString *)emailAddress completion:(void(^)(BOOL sent))completion {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    [manager GET:@"accounts/password/reset/"
       parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
        manager.responseSerializer = [AFHTTPResponseSerializer new];
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[operation.response allHeaderFields] forURL:[self loginURL]];

        // Django defaults to CSRF protection, so we need to get the token to send back in the request
        NSHTTPCookie *csrfCookie;
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"csrftoken"]) {
                csrfCookie = cookie;
            }
        }
          
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@accounts/password/reset/", self.baseURL] forHTTPHeaderField:@"Referer"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", csrfCookie.value] forHTTPHeaderField:@"X-CSRFToken"];
        [manager POST:@"accounts/password/reset/"
        parameters:@{ @"email": emailAddress }
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               NSLog(@"Reset sent: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
               
               if (completion) {
                   completion(YES);
               }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error during password reset POST: %@", error);
             
             if (completion) {
                 completion(NO);
             }
         }];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error during password reset GET: %@", error);
        
        if (completion) {
            completion(NO);
        }
    }];

}

#pragma mark - Phone Verification

- (void)sendPhoneNumberVerificationRequest:(NSString *)phoneNumber completion:(void (^)(id responseObject))completion {
    
    [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:[NSString stringWithFormat:@"%@send_sms_verification_code/", _loggedInUser.url]
    parameters:@{ @"phone_number": phoneNumber }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"sent PhoneNumberVerificationRequest");
           if (completion) {
               completion(nil);
           }
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           if (completion) {
               completion(operation.responseObject);
           }
           NSLog(@"PhoneNumberVerificationRequest Failed");
       }];
}

- (void)checkPhoneVerificationCode:(NSString *)codeFromUser completion:(void (^)(id responseObject))completion {
    
    [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:[NSString stringWithFormat:@"%@check_sms_verification_code/", _loggedInUser.url]
    parameters:@{ @"code": codeFromUser }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"Code Verified");
           if (completion) {
               completion(nil);
           }
           _loggedInUser.phoneNumberVerified = YES;
           [self archiveLoggedInUser];
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"Code Verification Failed");
           
           if (completion) {
               completion(operation.responseObject);
           }
       }];
}

#pragma mark - Emailmgr Add Remove Emails

- (void)addSecondaryEmail:(NSString *)email completion:(void(^)(BOOL success, NSString *errorMessage))completion {
    
    if (!email) {
        return;
    }
    
    email = [email lowercaseString];
    
    [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/email/add/"
    parameters:@{ @"email": email}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           
           [_loggedInUser updateWithAttributes:responseObject];
           
           if (completion) {
               completion(YES, nil);
           }
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSString *errorMessage = [operation.responseObject objectForKey:@"message"];
           if (!errorMessage) {
               errorMessage = error.localizedDescription;
           }
           
           NSLog(@"%@", errorMessage);
           if (completion) {
               completion(NO, errorMessage);
           }
       }];
}

- (void)makeSecondaryEmailPrimary:(NSString *)email completion:(void(^)(BOOL success, NSString *errorMessage))completion {
    
    if (!email) {
        return;
    }
    
    email = [email lowercaseString];
    
    [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/email/make_primary/"
    parameters:@{ @"email": email}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           
           [_loggedInUser updateWithAttributes:responseObject];
           
           if (completion) {
               completion(YES, nil);
           }
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSString *errorMessage = [operation.responseObject objectForKey:@"message"];
           if (!errorMessage) {
               errorMessage = error.localizedDescription;
           }
           
           NSLog(@"%@", errorMessage);
           if (completion) {
               completion(NO, errorMessage);
           }
       }];
}

- (void)resendSecondaryEmailActivation:(NSString *)email completion:(void(^)(BOOL success, NSString *errorMessage))completion {
    
    if (!email) {
        return;
    }
    
    email = [email lowercaseString];
    
    [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/email/send_activation/"
    parameters:@{ @"email": email}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           
           if (completion) {
               completion(YES, nil);
           }
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSString *errorMessage = [operation.responseObject objectForKey:@"message"];
           if (!errorMessage) {
               errorMessage = error.localizedDescription;
           }
           
           NSLog(@"%@", errorMessage);
           if (completion) {
               completion(NO, errorMessage);
           }
       }];
}

- (void)removeSecondaryEmail:(NSString *)email completion:(void(^)(BOOL success, NSString *errorMessage))completion {
    
    if (!email) {
        return;
    }
    
    email = [email lowercaseString];
    
    [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"api/email/delete/"
    parameters:@{ @"email": email}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"%@", responseObject);
           
           [_loggedInUser updateWithAttributes:responseObject];
           
           if (completion) {
               completion(YES, nil);
           }
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSString *errorMessage = [operation.responseObject objectForKey:@"message"];
           if (!errorMessage) {
               errorMessage = error.localizedDescription;
           }
           
           NSLog(@"%@", errorMessage);
           
           if (completion) {
               completion(NO, errorMessage);
           }
       }];
}

#pragma mark - Javelin API Token Methods

- (void)retrieveAPITokenForLoggedInUser:(void (^)(NSString *token))completion {
    if (![self retrieveArchivedLoggedInUser]) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    NSString *emailAddress = _loggedInUser.email;
    NSString *password = [self getPasswordForEmailAddress:_loggedInUser.email];

    if (emailAddress && password) {
        [self POST:[NSString stringWithFormat:@"%@api/retrieve-token/", self.baseURL]
        parameters:@{ @"username": emailAddress, @"password": password }
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               [self setAPITokenForLoggedInUser:responseObject[@"token"]];
               if (completion) {
                   completion(responseObject[@"token"]);
               }
               
               NSData *pushNotificationDeviceToken = [self retrieveLastArchivedAPNSDeviceToken];
               if (pushNotificationDeviceToken) {
                   [self setAPNSDeviceTokenForLoggedInUser:pushNotificationDeviceToken];
               }
               
               [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidRetrieveAPITokenNotification object:responseObject];
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"%@", error);
               if ([[TSJavelinAPIClient sharedClient] shouldRetry:error]) {
                   // Delay execution of my block for 10 seconds.
                   dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
                   dispatch_after(popTime, dispatch_get_main_queue(), ^{
                       [self retrieveAPITokenForLoggedInUser:completion];
                   });
               }
               else {
                   if (completion) {
                       completion(nil);
                   }
               }
               [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToRetrieveAPITokenNotification object:error];
           }
         ];
    }
}

- (void)setAPITokenForLoggedInUser:(NSString *)apiToken {
    _loggedInUser.apiToken = apiToken;
    [self archiveLoggedInUser];
}

- (NSString *)masterAccessTokenAuthorizationHeader {
    return [NSString stringWithFormat:@"Token %@", _masterAccessToken];
}

- (NSString *)loggedInUserTokenAuthorizationHeader {
    
    if (!_loggedInUser.apiToken) {
        [self retrieveAPITokenForLoggedInUser:nil];
    }
    
    return [NSString stringWithFormat:@"Token %@", _loggedInUser.apiToken];
}

#pragma mark - APNS Token Methods

- (void)archiveLatestAPNSDeviceToken:(NSData *)deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceToken forKey:kTSJavelinAPIAuthenticationManagerAPNSTokenArchiveKey];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidArchiveNewAPNSTokenNotification object:deviceToken];

    if (_loggedInUser) {
        [self setAPNSDeviceTokenForLoggedInUser:deviceToken];
    }
}

- (NSData *)retrieveLastArchivedAPNSDeviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *deviceToken = [defaults objectForKey:kTSJavelinAPIAuthenticationManagerAPNSTokenArchiveKey];
    return deviceToken;
}

- (void)setAPNSDeviceTokenForLoggedInUser:(NSData *)deviceToken {
    NSString *tokenString = [[[deviceToken description]
                              stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                             stringByReplacingOccurrencesOfString:@" " withString:@""];
    TSJavelinAPIUser *loggedInUser = [self loggedInUser];
    if (loggedInUser) {
        [self.requestSerializer setValue:[self loggedInUserTokenAuthorizationHeader]
                      forHTTPHeaderField:@"Authorization"];
        [self POST:[NSString stringWithFormat:@"%@update_device_token/", loggedInUser.url]
        parameters:@{ @"deviceToken": tokenString, @"deviceType": @"I" }
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               NSLog(@"DEVICE TOKEN UPDATED!");
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"%@", error);
           }
         ];
    }
}

#pragma mark - Utility Methods

- (NSURL *)loginURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@api/login/", [self.baseURL absoluteString]]];
}

- (void)makeLoginRequest:(NSMutableURLRequest *)request {
    if (request == nil) {
        request = [NSMutableURLRequest requestWithURL:[self loginURL]];
    }

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToCreateConnectionToAuthURL
                                                            object:self];
    }
}

- (void)storeUserCredentials:(NSString *)emailAddress password:(NSString *)password {
    
    if (!password) {
        return;
    }
    
    NSError *error;
    [SSKeychain setPassword:password forService:kTSJavelinAPIAuthenticationManagerKeyChainServiceName account:emailAddress error:&error];

    if (error) {
        NSLog(@"Error storing user credentials: %@", error);
    }
}

- (NSString *)getPasswordForEmailAddress:(NSString *)emailAddress {
    NSString *password = [SSKeychain passwordForService:kTSJavelinAPIAuthenticationManagerKeyChainServiceName account:emailAddress];
    return password;
}

- (void)setRegistrationRecoveryEmail:(NSString *)email Password:(NSString *)password {
    _emailAddress = email;
    _password = password;
    
    if (!_password) {
        _password = [self getPasswordForEmailAddress:email];
    }
}

- (TSJavelinAPIUser *)retrieveArchivedLoggedInUser {
    TSJavelinAPIUser *archivedUser;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedUserObject = [defaults objectForKey:kTSJavelinAPIAuthenticationManagerEncodedLoggedInUserArchiveKey];
    if (encodedUserObject) {
        archivedUser = (TSJavelinAPIUser *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedUserObject];
    }

    return archivedUser;
}

- (TSJavelinAPIUser *)loggedInUser {
    if (!_loggedInUser) {
        _loggedInUser = [self retrieveArchivedLoggedInUser];
    }

    return _loggedInUser;
}

- (void)archiveLoggedInUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedUserObject = [NSKeyedArchiver archivedDataWithRootObject:_loggedInUser];
    [defaults setObject:encodedUserObject forKey:kTSJavelinAPIAuthenticationManagerEncodedLoggedInUserArchiveKey];
    [defaults synchronize];
}

- (void)removeArchivedLoggedInUser {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [_loggedInUser setUserProfile:_loggedInUser.userProfile];
    [defaults synchronize];
}

- (void)setLoggedInUser:(TSJavelinAPIUser *)loggedInUser {
    _loggedInUser = loggedInUser;
    [self archiveLoggedInUser];
}

- (void)deleteCookiesForLoginDomain {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:[self loginURL].host];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if ([_delegate respondsToSelector:@selector(loginFailed:error:)]) {
        [_delegate loginFailed:nil error:error];
    }
    
    if (_loginCompletionBlock) {
        _loginCompletionBlock(nil);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    __block TSJavelinAPIAuthenticationResult *result = [TSJavelinAPIAuthenticationResult authenticationResultFromResponse:response];

    if (result.statusCode == 200) {
        // We're logged in and good to go
        [self storeUserCredentials:_emailAddress password:_password];
        _emailAddress = nil;
        _password = nil;

        [self deleteCookiesForLoginDomain];
    }
    else {
        [connection cancel];

        if (result.statusCode == 401) {
            if ([result.responseHeaders objectForKey:@"Auth-Response"]) {
                NSString *authResponse = [result.responseHeaders objectForKey:@"Auth-Response"];
                if ([authResponse isEqualToString:@"Login failed"]) {
                    // Incorrect credentials
                    result.loginFailureReason = kTSJavelinAPIAuthenticationManagerLoginFailureInvalidCredentials;
                    if ([_delegate respondsToSelector:@selector(loginFailed:error:)]) {
                        [_delegate loginFailed:result error:nil];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToLogin object:result];
                    
                    if (_loginCompletionBlock) {
                        _loginCompletionBlock(nil);
                    }
                }
                else if ([authResponse isEqualToString:@"Email unverified"]) {
                    // Unverified email address
                    result.loginFailureReason = kTSJavelinAPIAuthenticationManagerLoginFailureUnverifiedEmail;
                    if ([_delegate respondsToSelector:@selector(loginFailed:error:)]) {
                        [_delegate loginFailed:result error:nil];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToLogin object:result];
                    
                    if (_loginCompletionBlock) {
                        _loginCompletionBlock(nil);
                    }
                }
            }
            else {
                // Not logged in, so let's try logging in...
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self loginURL]];
                [request setHTTPMethod:@"POST"];

                NSString *authString = [NSString stringWithFormat:@"username=%@;password=%@;", _emailAddress, _password, nil];
                [request setHTTPBody:[authString dataUsingEncoding:NSUTF8StringEncoding]];
                [self makeLoginRequest:request];

            }
        }
        else if (result.statusCode == 403) {
            // Account is inactive, tough luck...
            result.loginFailureReason = kTSJavelinAPIAuthenticationManagerLoginFailureInactiveAccount;
            if ([_delegate respondsToSelector:@selector(loginFailed:error:)]) {
                [_delegate loginFailed:result error:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToLogin object:result];

            if (_loginCompletionBlock) {
                _loginCompletionBlock(nil);
            }
        }
        else if (result.statusCode == 500) {
            
            // Server error, shit...
            result.loginFailureReason = kTSJavelinAPIAuthenticationManagerLoginFailureServerError;
            if ([_delegate respondsToSelector:@selector(loginFailed:error:)]) {
                [_delegate loginFailed:result error:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToLogin object:result];
            
            if (_loginCompletionBlock) {
                _loginCompletionBlock(nil);
            }
        }
        else {
            //I don't know
            
            result.loginFailureReason = kTSJavelinAPIAuthenticationManagerLoginFailureUnknownError;
            if ([_delegate respondsToSelector:@selector(loginFailed:error:)]) {
                [_delegate loginFailed:result error:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidFailToLogin object:result];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Should only get here with a 200 status code
    NSError *error;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    else {
        [self setLoggedInUser:[[TSJavelinAPIUser alloc] initWithAttributes:responseJSON]];
        
        [self retrieveAPITokenForLoggedInUser:^(NSString *token) {
            if (_loginCompletionBlock) {
                _loginCompletionBlock(_loggedInUser);
            }
        }];
        
        if ([_delegate respondsToSelector:@selector(loginSuccessful:)]) {
            [_delegate loginSuccessful:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAPIAuthenticationManagerDidLoginSuccessfully object:_loggedInUser];
    }
    [self.responseData setLength:0];
}



@end
