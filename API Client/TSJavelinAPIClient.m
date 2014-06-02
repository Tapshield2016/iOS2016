//
//  TSJavelinAPIClient.m
//  Javelin
//
//  Created by Ben Boyd on 11/5/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TSJavelinAlertManager.h"
#import "TSJavelinAPIMassAlert.h"
#import "TSJavelinAPIAlert.h"
#import "TSJavelinAPIAgency.h"
#import "TSJavelinAPIUser.h"
#import "TSJavelinAPIChatMessage.h"
#import "TSJavelinChatManager.h"
#import "TSJavelinAPIUserProfile.h"
#import "TSJavelinAPIUtilities.h"
#import "TSJavelinAPISocialCrimeReport.h"

@interface TSJavelinAPIClient ()

@property (nonatomic, strong) NSString *baseAuthURL;
@property (nonatomic, strong) NSTimer *disarmRetryTimer;
@property (nonatomic, strong) NSTimer *timerForFailedFindActiveAlertURL;

@end

@implementation TSJavelinAPIClient

static TSJavelinAPIClient *_sharedClient = nil;
static dispatch_once_t onceToken;

+ (instancetype)initializeSharedClientWithBaseURL:(NSString *)baseURL andBaseAuthURL:(NSString *)baseAuthURL {
    if (!_sharedClient) {
        dispatch_once(&onceToken, ^{
            _sharedClient = [[TSJavelinAPIClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        });
        [AmazonErrorHandler shouldNotThrowExceptions];

        // Enable the network activity manager
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

        _sharedClient.alertManager = [TSJavelinAlertManager sharedManager];

        _sharedClient.chatManager = [TSJavelinChatManager sharedManager];

        if (baseAuthURL == nil) {
            NSURL *authURL = [NSURL URLWithString:baseURL];
            baseAuthURL = [NSString stringWithFormat:@"%@://%@", [authURL scheme], [authURL host]];
            if ([authURL port] && ![[authURL port] isEqual: @(80)]) {
                baseAuthURL = [NSString stringWithFormat:@"%@:%@/", baseAuthURL, [authURL port]];
            }
            else {
                baseAuthURL = [NSString stringWithFormat:@"%@/", baseAuthURL];
            }
        }
        
        _sharedClient.baseAuthURL = baseAuthURL;

        // Initialize shared auth client
        _sharedClient.authenticationManager = [TSJavelinAPIAuthenticationManager initializeSharedManagerWithBaseAuthURL:baseAuthURL];
        [_sharedClient.authenticationManager loggedInUser];
    }
    
    return _sharedClient;
}

+ (instancetype)initializeSharedClientWithBaseURL:(NSString *)baseURL {
    return [TSJavelinAPIClient initializeSharedClientWithBaseURL:baseURL andBaseAuthURL:nil];
}

+ (instancetype)sharedClient {
    if (_sharedClient == nil) {
        [NSException raise:@"Shared Client Not Initialized"
                    format:@"Before calling [TSJavelinAPIClient sharedClient] you must first initialize the shared client"];
    }
    
    return _sharedClient;
}

// Generic method for creating an array of API-specific objects
- (NSArray *)apiObjectArrayOfClass:(NSString *)className fromJSON:(id)JSON withKey:(NSString *)key {
    NSArray *results = [JSON objectForKey:key];
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[results count]];
    for (NSDictionary *attributes in results) {
        [objects addObject:[[NSClassFromString(className) alloc] initWithAttributes:attributes]];
    }
    
    return objects;
}

#pragma mark - Agency Methods

- (void)getAgencies:(void (^)(NSArray *agencies))completion {
    [self.requestSerializer setValue:[[self authenticationManager] masterAccessTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:@"agencies/"
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (completion) {
              completion([self apiObjectArrayOfClass:@"TSJavelinAPIAgency" fromJSON:responseObject withKey:@"results"]);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          
          dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
          dispatch_after(popTime, dispatch_get_main_queue(), ^{
              if ([self shouldRetry:error]) {
                  [self getAgencies:completion];
              }
          });
      }];
}

- (void)getAgenciesNearby:(CLLocation *)currentLocation radius:(float)radius completion:(void (^)(NSArray *agencies))completion {
    [self.requestSerializer setValue:[[self authenticationManager] masterAccessTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:@"agencies/"
   parameters:@{@"latitude": [[NSNumber numberWithDouble:currentLocation.coordinate.latitude] stringValue],
                @"longitude": [[NSNumber numberWithDouble:currentLocation.coordinate.longitude] stringValue],
                @"distance_within": [[NSNumber numberWithFloat:radius] stringValue]}
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (completion) {
              completion([self apiObjectArrayOfClass:@"TSJavelinAPIAgency" fromJSON:responseObject withKey:@"results"]);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
          dispatch_after(popTime, dispatch_get_main_queue(), ^{
              if ([self shouldRetry:error]) {
                  [self getAgenciesNearby:currentLocation radius:radius completion:completion];
              }
          });
      }];
}

- (void)getAgencyForLoggedInUser:(void (^)(TSJavelinAPIAgency *agency))completion {
    
    if (![[self authenticationManager] loggedInUser].agency.url) {
        return;
    }
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:[[self authenticationManager] loggedInUser].agency.url
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          TSJavelinAPIAgency *agency = [[TSJavelinAPIAgency alloc] initWithAttributes:responseObject];
          [[self authenticationManager] loggedInUser].agency = agency;
          [[self authenticationManager] archiveLoggedInUser];
          if (completion) {
              completion(agency);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          
          if ([self shouldRetry:error]) {
              // Delay execution of my block for 10 seconds.
              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
              dispatch_after(popTime, dispatch_get_main_queue(), ^{
                  [self getAgencyForLoggedInUser:completion];
              });
          }
          else {
              if (completion) {
                  completion(nil);
              }
          }
      }];
}

- (void)getUserAgencyForUrl:(NSString *)agencyUrl completion:(void (^)(TSJavelinAPIAgency *agency))completion {
    
    if (!agencyUrl) {
        return;
    }
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:agencyUrl
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          TSJavelinAPIAgency *agency = [[TSJavelinAPIAgency alloc] initWithAttributes:responseObject];
          [[self authenticationManager] loggedInUser].agency = agency;
          [[self authenticationManager] archiveLoggedInUser];
          if (completion) {
              completion(agency);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          
          if ([self shouldRetry:error]) {
              // Delay execution of my block for 10 seconds.
              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
              dispatch_after(popTime, dispatch_get_main_queue(), ^{
                  [self getUserAgencyForUrl:agencyUrl completion:completion];
              });
          }
          else {
              if (completion) {
                  completion(nil);
              }
          }
      }];
}

#pragma mark - Mass Alert Methods

- (void)getMassAlerts:(void (^)(NSArray *massAlerts))completion {
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:@"mass-alerts/"
   parameters:@{ @"agency" : @([[self authenticationManager] loggedInUser].agency.identifier) }
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (completion) {
              completion([self apiObjectArrayOfClass:@"TSJavelinAPIMassAlert" fromJSON:responseObject withKey:@"results"]);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          if (completion) {
              completion(nil);
          }
      }];
}

- (void)receivedNotificationOfNewMassAlert:(NSDictionary *)notification {
#warning What to do?
}

#pragma mark - Alert Methods

- (void)sendEmergencyAlertWithAlertType:(NSString *)type location:(CLLocation *)location completion:(void (^)(BOOL sent, BOOL inside))completion {
    _isStillActiveAlert = YES;
    TSJavelinAPIAlert *alert = [[TSJavelinAPIAlert alloc] init];
    alert.agencyUser = [[TSJavelinAPIAuthenticationManager sharedManager] loggedInUser];

    if (!alert.agencyUser) {
        completion(NO, NO);
        return;
    }
    
    [[TSJavelinAlertManager sharedManager] initiateAlert:alert type:type location:location completion:^(BOOL sent, BOOL inside) {
        
        if (!sent && inside) {
            
                // Delay execution of my block for 5 seconds.
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^{
                    if ([TSJavelinAPIClient sharedClient].isStillActiveAlert) {
                        [self sendEmergencyAlertWithAlertType:type location:location completion:completion];
                    }
                });
        }
        else {
            if (completion) {
                completion(sent, inside);
            }
        }
    }];
}

- (void)findActiveAlertForLoggedinUser:(void (^)(TSJavelinAPIAlert *activeAlert))completion {
    
    [self getActiveAlertWithStatus:@[@"N", @"A", @"P"] fromObject:0 completion:^(TSJavelinAPIAlert *activeAlert) {
        if (completion) {
            completion(activeAlert);
        }
    }];
}

- (void)getActiveAlertWithStatus:(NSArray *)statuses fromObject:(NSUInteger)index completion:(void (^)(TSJavelinAPIAlert *activeAlert))completion {
    
    if (index >= statuses.count) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:@"alerts/"
   parameters:@{ @"agency_user": [NSString stringWithFormat:@"%lu", (unsigned long)[[self authenticationManager] loggedInUser].identifier],
                 @"status": statuses[index] }
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if ([responseObject[@"results"] count] > 0) {
              TSJavelinAPIAlert *foundAlert = [[TSJavelinAPIAlert alloc] initWithAttributes:responseObject[@"results"][0]];
              NSLog(@"active alert found");
              if (completion) {
                  completion(foundAlert);
              }
          }
          else {
              [self getActiveAlertWithStatus:statuses fromObject:index + 1 completion:completion];
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          
          if ([self shouldRetry:error]) {
              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
              dispatch_after(popTime, dispatch_get_main_queue(), ^{
                  [self getActiveAlertWithStatus:statuses fromObject:index completion:completion];
              });
          }
          
      }];
}



- (void)uploadUserProfileData:(TSJavelinAPIUserProfileUploadBlock)completion {
    
    // We've already created the provided profile, maybe loaded it from disk or whatever
    TSJavelinAPIUserProfile *userProfileObject = [[self authenticationManager] loggedInUser].userProfile;
    NSDictionary *profileAttributes = [userProfileObject dictionaryFromAttributes];
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"user-profiles/"
    parameters:profileAttributes
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           if (responseObject) {
               
               _profileUploadBlock = completion;
               TSJavelinAPIUserProfile *responseProfile = [[TSJavelinAPIUserProfile alloc] initWithAttributes:responseObject];
               [[self authenticationManager] loggedInUser].userProfile.url = responseProfile.url;
               [self uploadUserProfileImageAndPatch:responseProfile.url];
           }
           
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [self GET:@"user-profiles/"
        parameters:@{ @"user": @([[self authenticationManager] loggedInUser].identifier) }
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               if ([responseObject[@"results"] count] > 0) {
                   TSJavelinAPIUserProfile *profile = [[TSJavelinAPIUserProfile alloc] initWithAttributes:responseObject[@"results"][0]];
                   [self PATCH:profile.url
                    parameters:profileAttributes
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           
                           _profileUploadBlock = completion;
                           TSJavelinAPIUserProfile *responseProfile = [[TSJavelinAPIUserProfile alloc] initWithAttributes:responseObject];
                           [[self authenticationManager] loggedInUser].userProfile.url = responseProfile.url;
                           [self uploadUserProfileImageAndPatch:responseProfile.url];
                           
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           if (completion) {
                               completion(NO, NO);
                               NSLog(@"UserProfile failed to Patch");
                           }
                       }];
               }
               else {
                   if (completion) {
                       completion(NO, NO);
                       NSLog(@"No Response Object");
                   }
               }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (completion) {
                   completion(NO, NO);
                   NSLog(@"failed to Get userProfile");
               }
         }];
       }];
}

- (void)uploadUserProfileImageAndPatch:(NSString *)userProfileURL {
    // use profile.url
    TSJavelinAPIUserProfile *userProfileObject = [[self authenticationManager] loggedInUser].userProfile;
    // upload image on background thread
    
    if (userProfileObject.profileImage) {
        _uploadManager = [[TSJavelinS3UploadManager alloc] init];
        [_uploadManager uploadUIImageToS3:userProfileObject.profileImage
                                imageName:[NSString stringWithFormat:@"profile-images/%@.jpg", [TSJavelinAPIUtilities uuidString]]
                               completion:^(NSString *imageS3URL) {
                                   
                                   if (imageS3URL) {
                                       [self PATCH:userProfileURL
                                        parameters:@{@"profile_image_url": imageS3URL}
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               _profileUploadBlock(YES, YES);
                                               NSLog(@"UserProfile uploaded, uploadUIImage Success, userProfile patched");
                                           }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               _profileUploadBlock(YES, NO);
                                               NSLog(@"UserProfile uploaded, uploadUIImage Success, userProfile patch failed");
                                           }];
                                   }
                                   else {
                                       _profileUploadBlock(YES, NO);
                                       NSLog(@"UserProfile uploaded, uploadUIImage failed");
                                   }
                               }];
    }
    else {
        _profileUploadBlock(YES, YES);
        NSLog(@"UserProfile uploaded, no image to upload");
    }
}

#pragma mark Location Updates

- (void)locationUpdated:(CLLocation *)location {
    TSJavelinAPIAlert *activeAlert = [[TSJavelinAlertManager sharedManager] activeAlert];
    if (!activeAlert || !activeAlert.url) {
        return;
    }
    
    if (!_isStillActiveAlert) {
        return;
    }
    
    
    _locationAwaitingPost = location;
    
    if (!_locationPostTimer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _locationPostTimer = [NSTimer scheduledTimerWithTimeInterval:20
                                                                  target:self
                                                                selector:@selector(sendLocationUpdate:)
                                                                userInfo:nil
                                                                 repeats:YES];
            [self sendLocationUpdate:location];
            return;
        });
    }
    
    if (location.coordinate.latitude == _previouslyPostedLocation.coordinate.latitude && location.coordinate.longitude == _previouslyPostedLocation.coordinate.longitude) {
        return;
    }
    
    //Send Location right away if enough time has passed or accuracy increased
    NSTimeInterval timeOfPreviousLocation = [_previouslyPostedLocation.timestamp timeIntervalSinceNow];
    if (abs(timeOfPreviousLocation) > 20 || location.horizontalAccuracy < _previouslyPostedLocation.horizontalAccuracy) {
        [self sendLocationUpdate:location];
    }
}

- (void)sendLocationUpdate:(CLLocation *)location {
    
    if (!_isStillActiveAlert) {
        [_locationPostTimer invalidate];
        return;
    }
    
    if (![location isKindOfClass:[CLLocation class]] || !location) {
        location = _locationAwaitingPost;
    }
    
    TSJavelinAPIAlert *activeAlert = [[TSJavelinAlertManager sharedManager] activeAlert];
    
    //Check to make sure location needs to be sent
    if (_previouslyPostedLocation) {
        if ([location distanceFromLocation:_previouslyPostedLocation] < 5 && location.horizontalAccuracy >= _previouslyPostedLocation.horizontalAccuracy) {
            return;
        }
    }
    NSLog(@"New location distance change = %f", [location distanceFromLocation:_previouslyPostedLocation]);
    _previouslyPostedLocation = location;
    
    if (!activeAlert.url) {
        return;
    }
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"alert-locations/"
    parameters:@{ @"alert": activeAlert.url,
                  @"accuracy": [NSNumber numberWithDouble:location.horizontalAccuracy],
                  @"altitude": [NSNumber numberWithDouble:location.altitude],
                  @"latitude": [NSNumber numberWithDouble:location.coordinate.latitude],
                  @"longitude": [NSNumber numberWithDouble:location.coordinate.longitude] }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"Successfully created new alert location: %@", responseObject);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"Failed to create new alert location: %@", error);
       }];
}


#pragma mark Disarm Alert

- (void)startTimerForFailedDisarmOfURL:(NSString *)activeAlertURL
{
    if (_disarmRetryTimer) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _disarmRetryTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                             target:self
                                                           selector:@selector(postDisarmedFromTimer:)
                                                           userInfo:@{@"URL": activeAlertURL}
                                                            repeats:YES];
    });
    
}

- (void)postDisarmedFromTimer:(NSTimer *)disarmRetryTimer {
    
    NSDictionary *userInfo = [disarmRetryTimer userInfo];
    [self postDisarmedToActiveAlertURL:[userInfo objectForKey:@"URL"]];
}

- (void)startTimerForFailedFindActiveAlertURL
{
    if (_disarmRetryTimer) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _timerForFailedFindActiveAlertURL = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                                             target:self
                                                                           selector:@selector(findActiveAlertAndCancel)
                                                                           userInfo:nil
                                                                            repeats:YES];
    });
}

- (void)cancelAlert {
    
    _isStillActiveAlert = NO;
    [_locationPostTimer invalidate];
    _locationPostTimer = nil;
    [[TSJavelinAlertManager sharedManager] stopAlertUpdates];
    [[TSJavelinAPIClient sharedClient] clearChatMessages];
}

- (void)disarmAlert {
    TSJavelinAPIAlert *activeAlert = [[TSJavelinAlertManager sharedManager] activeAlert];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kTSJavelinAlertManagerSentActiveAlert]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTSJavelinAlertManagerAwaitingDisarm];
        
        if (activeAlert.url) {
            [self postDisarmedToActiveAlertURL:activeAlert.url];
        }
        else {
            [self findActiveAlertAndCancel];
        }
    }
}

- (void)findActiveAlertAndCancel {
    
    [self findActiveAlertForLoggedinUser:^(TSJavelinAPIAlert *activeAlert) {
        if (!activeAlert) {
            [self startTimerForFailedFindActiveAlertURL];
            return;
        }
        [_timerForFailedFindActiveAlertURL invalidate];
        [self postDisarmedToActiveAlertURL:activeAlert.url];
    }];
}

- (void)postDisarmedToActiveAlertURL:(NSString *)activeAlertURL {
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:[NSString stringWithFormat:@"%@disarm/", activeAlertURL]
    parameters:nil
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"DISARMED ALERT: %@", responseObject);
           [[self alertManager] setActiveAlert:nil];
           [_timerForFailedFindActiveAlertURL invalidate];
           [_disarmRetryTimer invalidate];
           [[TSJavelinAlertManager sharedManager] resetArchivedAlertBools];
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"FAILED TO DISARM ALERT: %@", error);
           [self startTimerForFailedDisarmOfURL:activeAlertURL];
       }
     ];
}


- (void)alertReceiptReceivedForAlertWithURL:(NSString *)url {
    if (!_isStillActiveAlert) {
        [self postDisarmedToActiveAlertURL:url];
        return;
    }
    [[self alertManager] alertReceiptReceivedForAlertWithURL:url];
}



#pragma mark - Chat Message Methods

- (void)startChatForActiveAlert {
    
    [_chatManager startChatForActiveAlert];
}

- (void)clearChatMessages {
    
    [_chatManager clearChatMessages];
}

- (void)sendChatMessage:(NSString *)message {
    
    [_chatManager sendChatMessage:message];
}

- (void)sendChatMessageForActiveAlert:(TSJavelinAPIChatMessage *)chatMessage completion:(void (^)(ChatMessageStatus status))completion {
    [_chatManager sendChatMessageForActiveAlert:chatMessage completion:completion];
}

- (void)getChatMessagesForActiveAlert:(void (^)(NSArray *chatMessages))completion {
    [_chatManager getChatMessagesForActiveAlert:completion];
}

- (void)getChatMessagesForActiveAlertSinceTime:(NSDate *)dateTime completion:(void (^)(NSArray *chatMessages))completion {
    [_chatManager getChatMessagesForActiveAlertSinceTime:dateTime completion:completion];
}

- (void)receivedNotificationOfNewChatMessageAvailableForActiveAlert:(NSDictionary *)notification {
    [_chatManager receivedNotificationOfNewChatMessageAvailableForActiveAlert:notification];
}

#pragma mark - Twilio Voip Methods

- (void)getTwilioCallToken:(void (^)(NSString *callToken))completion {
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:[NSString stringWithFormat:@"%@api/twilio-call-token/", _baseAuthURL]
     parameters:@{ @"user": @([[self authenticationManager] loggedInUser].identifier) }
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (completion) {
              completion([(NSDictionary *)responseObject objectForKey:@"token"]);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          if (completion) {
              completion(nil);
          }
      }];
    
}

#pragma mark - Entourage Methods

/*
Associating a new Entourage Member with a User (via POST method):
curl https://dev.tapshield.com/api/v1/entourage-members/ -d "user=/api/v1/users/1/&name=Test Member&phone_number=5435435454" -H "Authorization: Token 35204055c8518dd538f563ee729e70acef71cfeb"

Edit
Deleting an Entourage Member from a User's entourage group (via DELETE method):
curl -XDELETE https://dev.tapshield.com/api/v1/entourage-members/5/ -H "Authorization: Token 35204055c8518dd538f563ee729e70acef71cfeb"

Edit
Messaging a User's entourage (via POST method):
curl https://dev.tapshield.com/api/v1/users/1/message_entourage/ --data "message=Ben arrived at this destination." -H "Authorization: Token e9e9df293943bee2a9c7dd96fa88b95bd352acf5"
 */


- (void)notifyEntourageMembers:(NSString *)message completion:(void (^)(id responseObject, NSError *error))completion {
    
    if (!message) {
        return;
    }
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:[NSString stringWithFormat:@"%@message_entourage/", [[self authenticationManager] loggedInUser].url]
    parameters:@{@"message": message}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           if (completion) {
               completion(responseObject, nil);
           }
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"%@", error);
           
           if ([self shouldRetry:error]) {
               // Delay execution of my block for 10 seconds.
               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
               dispatch_after(popTime, dispatch_get_main_queue(), ^{
                   [self notifyEntourageMembers:message completion:completion];
               });
           }
           else {
               if (completion) {
                   completion(nil, error);
               }
           }
       }];
}

- (void)addEntourageMember:(TSJavelinAPIEntourageMember *)member completion:(void (^)(id responseObject, NSError *error))completion {
    
    if (member.identifier) {
        NSLog(@"Entourage member already has a url");
        if (completion) {
            completion(member, nil);
        }
        return;
    }
    
    NSDictionary *parameters = [member parametersFromMember];
    if (!parameters) {
        NSLog(@"Entourage Member missing parameters");
        if (completion) {
            completion(member, nil);
        }
        return;
    }
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"entourage-members/"
   parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          member.url = [responseObject objectForKey:@"url"];
          
          if (completion) {
              completion(member, nil);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          
          if ([self shouldRetry:error]) {
              // Delay execution of my block for 10 seconds.
              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
              dispatch_after(popTime, dispatch_get_main_queue(), ^{
                  [self addEntourageMember:member completion:completion];
              });
          }
          else {
              if (completion) {
                  completion(nil, error);
              }
          }
      }];
}


- (void)removeEntourageMember:(TSJavelinAPIEntourageMember *)member completion:(void (^)(id responseObject, NSError *error))completion {
    
    if (!member.url) {
        NSLog(@"Entourage Member missing url");
        return;
    }
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self DELETE:member.url
    parameters:nil
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           if (completion) {
               completion(member, nil);
           }
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"%@", error);
           
           if ([self shouldRetry:error]) {
               // Delay execution of my block for 10 seconds.
               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
               dispatch_after(popTime, dispatch_get_main_queue(), ^{
                   [self removeEntourageMember:member completion:completion];
               });
           }
           else {
               if (completion) {
                   completion(nil, error);
               }
           }
       }];
}

#pragma mark - Social Reporting 

//Given a latitude, longitude, and a distance radius, you can get a list of socially-reported crimes/suspicious incidents that surround the user. These are reported by other users of the app.
//
//Example:
//
//https://dev.tapshield.com/api/v1/social-crime-reports/?latitude=28.54242&longitude=-81.375586&distance_within=10
//
//All 3 parameters are required if you wish to perform this type of search - omitting any of the three parameters will end in an empty result. Providing a non-numerical value for any of the three will result in a 500 error from the server.
//
//Results will be ordered from nearest to farthest from the location provided and will include a distance field in miles that represents the distance to the organization.
//
//The distance_within parameter is a value in miles and can be specified as a float if desired, e.g. 0.3, 97.8, etc.

- (void)getSocialCrimeReports:(CLLocation *)location radius:(float)radius completion:(void (^)(NSArray *reports))completion {
    
    if (!location || !radius) {
        return;
    }
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self GET:@"social-crime-reports/"
   parameters:@{ @"latitude": @(location.coordinate.latitude),
                 @"longitude": @(location.coordinate.longitude),
                 @"distance_within": @(radius)}
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (completion) {
              completion([TSJavelinAPISocialCrimeReport socialCrimeReportArray:[responseObject objectForKey:@"results"]]);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          if (completion) {
              completion(nil);
          }
      }];
    
}


//
//You may also POST new crime reports as you do other objects in the API. Note that report_point is created automatically when the object is saved, so you only need to supply report_latitude and report_longitude.
//
//reporter, body, report_type, report_latitude and report_longitude are required fields. report_image_url will be unused for now but preserved for future use (clients will be responsible for uploading image assets to S3 and supplying the resulting URL to the API).

- (void)postSocialCrimeReport:(TSJavelinAPISocialCrimeReport *)report completion:(void (^)(TSJavelinAPISocialCrimeReport *report))completion {
    
    NSArray *shortArray = [NSArray arrayWithObjects:kSocialCrimeReportShortArray];
    
    if (!report.body || report.reportType >= shortArray.count || !report.location) {
        return;
    }
    
    NSDictionary *requiredParam = @{@"reporter": [[self authenticationManager] loggedInUser].url,
                                    @"body": report.body,
                                    @"report_type": shortArray[report.reportType],
                                    @"report_latitude": @(report.location.coordinate.latitude),
                                    @"report_longitude": @(report.location.coordinate.longitude)};
    
    NSMutableDictionary *paramaters = [[NSMutableDictionary alloc] initWithDictionary:requiredParam];
    
    if (report.reportAudioUrl.length) {
        [paramaters setObject:report.reportAudioUrl forKey:@"report_audio_url"];
    }
    if (report.reportImageUrl.length) {
        [paramaters setObject:report.reportImageUrl forKey:@"report_image_url"];
    }
    if (report.reportVideoUrl.length) {
        [paramaters setObject:report.reportVideoUrl forKey:@"report_video_url"];
    }
    
    [self.requestSerializer setValue:[[self authenticationManager] loggedInUserTokenAuthorizationHeader]
                  forHTTPHeaderField:@"Authorization"];
    [self POST:@"social-crime-reports/"
    parameters:paramaters
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           if (completion) {
               completion([[TSJavelinAPISocialCrimeReport alloc] initWithAttributes:responseObject]);
           }
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"%@", error);
           
           if ([self shouldRetry:error]) {
               // Delay execution of my block for 10 seconds.
               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
               dispatch_after(popTime, dispatch_get_main_queue(), ^{
               });
           }
           else {
               if (completion) {
                   completion(nil);
               }
           }
       }];
}


#pragma mark - Error Codes

- (BOOL)shouldRetry:(NSError *)error {
    
    /*
     No Connection errors
     
     NSURLErrorCannotFindHost = -1003,
     
     NSURLErrorCannotConnectToHost = -1004,
     
     NSURLErrorNetworkConnectionLost = -1005,
     
     NSURLErrorDNSLookupFailed = -1006,
     
     NSURLErrorHTTPTooManyRedirects = -1007,
     
     NSURLErrorResourceUnavailable = -1008,
     
     NSURLErrorNotConnectedToInternet = -1009,
     
     NSURLErrorRedirectToNonExistentLocation = -1010,
     
     NSURLErrorInternationalRoamingOff = -1018,
     
     NSURLErrorCallIsActive = -1019,
     
     NSURLErrorDataNotAllowed = -1020,
     
     NSURLErrorSecureConnectionFailed = -1200,
     
     NSURLErrorCannotLoadFromNetwork = -2000,
     */
    
    NSArray *networkFailureCodes = @[@(NSURLErrorCannotFindHost),
                                     @(NSURLErrorCannotConnectToHost),
                                     @(NSURLErrorNetworkConnectionLost),
                                     @(NSURLErrorDNSLookupFailed),
                                     @(NSURLErrorHTTPTooManyRedirects),
                                     @(NSURLErrorResourceUnavailable),
                                     @(NSURLErrorNotConnectedToInternet),
                                     @(NSURLErrorRedirectToNonExistentLocation),
                                     @(NSURLErrorInternationalRoamingOff),
                                     @(NSURLErrorCallIsActive),
                                     @(NSURLErrorDataNotAllowed),
                                     @(NSURLErrorSecureConnectionFailed),
                                     @(NSURLErrorCannotLoadFromNetwork)];
    
    BOOL networkError = NO;
    if (error) {
        for (NSNumber *number in networkFailureCodes) {
            if (error.code == [number integerValue]) {
                NSLog(@"%i", error.code);
                networkError = YES;
            }
        }
    }
    
    if (!networkError) {
        return NO;
    }
    
    return YES;
}

@end
