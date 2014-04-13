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
          if (completion) {
              completion(nil);
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

- (void)sendEmergencyAlertWithAlertType:(NSString *)type location:(CLLocation *)location completion:(void (^)(BOOL success))completion {
    _isStillActiveAlert = YES;
    TSJavelinAPIAlert *alert = [[TSJavelinAPIAlert alloc] init];
    alert.agencyUser = [[TSJavelinAPIAuthenticationManager sharedManager] loggedInUser];

    if (!alert.agencyUser) {
        completion(NO);
        return;
    }
    
    [[TSJavelinAlertManager sharedManager] initiateAlert:alert type:type location:location completion:^(BOOL success) {
        if (success) {
            NSLog(@"Success!");
            completion(success);
        }
        else {
            completion(NO);
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
          [self getActiveAlertWithStatus:statuses fromObject:index + 1 completion:completion];
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
      }];
    
}

@end
