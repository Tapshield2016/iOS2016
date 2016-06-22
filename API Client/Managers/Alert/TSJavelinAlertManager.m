//
//  TSJavelinAlertManager.m
//  Javelin
//
//  Created by Ben Boyd on 10/30/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAlertManager.h"
#import "TSJavelinAPIAlert.h"
#import "TSJavelinAPIUser.h"
#import "TSJavelinAlertAMQPMessage.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIUtilities.h"
#import "TSJavelinAPIAgency.h"
#import "TSGeofence.h"
#import "TSLocationGeofenceTestView.h"
#import <AFNetworkReachabilityManager.h>
#import <MapKit/MapKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSCore/AWSService.h>
#import <AWSSQS/AWSSQS.h>

static NSString * const kTSJavelinAlertManagerSQSDevelopmentAccessKey = @"AKIAJSDRUWW6PPF2FWWA";
static NSString * const kTSJavelinAlertManagerSQSDevelopmentSecretKey = @"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";
static NSString * const kTSJavelinAlertManagerSQSDevelopmentAlertQueueName = @"alert_queue_dev";

static NSString * const kTSJavelinAlertManagerSQSKey = @"kTSJavelinAlertManagerSQSKey";

static NSString * const kTSJavelinAlertManagerSQSDemoAlertQueueName = @"alert_queue_demo";

static NSString * const kTSJavelinAlertManagerSQSProductionAccessKey = @"AKIAJDLBPGLRJA4MOMVQ";
static NSString * const kTSJavelinAlertManagerSQSProductionSecretKey = @"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";
static NSString * const kTSJavelinAlertManagerSQSProductionAlertQueueName = @"alert_queue_prod";

#ifdef DEV
static NSString * const TSJavelinAlertManagerRemoteHostName = @"dev.tapshield.com";
#elif DEMO
static NSString * const TSJavelinAlertManagerRemoteHostName = @"demo.tapshield.com";
#elif APP_STORE
static NSString * const TSJavelinAlertManagerRemoteHostName = @"api.tapshield.com";
#else
static NSString * const TSJavelinAlertManagerRemoteHostName = @"dev.tapshield.com";
#endif

NSString * const TSJavelinAlertManagerDidReceiveActiveAlertNotification = @"TSJavelinAlertManagerDidReceiveActiveAlertNotification";
NSString * const TSJavelinAlertManagerDidDisarmNotification = @"TSJavelinAlertManagerDidDisarmNotification";
NSString * const TSJavelinAlertManagerDidSendAlertOutsideGeofenceNotification = @"TSJavelinAlertManagerDidSendAlertOutsideGeofenceNotification";

NSString * const kTSJavelinAlertManagerSentActiveAlert = @"kTSJavelinAlertManagerSentActiveAlert";
NSString * const kTSJavelinAlertManagerAwaitingDisarm = @"kTSJavelinAlertManagerAwaitingDisarm";

NSString * const kTSJavelinAlertManagerDidNotFindAlert = @"kTSJavelinAlertManagerNoResponse";

NSString * const TSJavelinAlertManagerDidReceiveAlertCompletion = @"TSJavelinAlertManagerDidReceiveAlertCompletion";

@interface TSJavelinAlertManager ()

@property (nonatomic, strong) AWSSQS *sqs;
@property (nonatomic, assign) CLLocation *lastReportedLocation;
@property (nonatomic, assign) BOOL locationUpdatesInProgress;
@property (nonatomic, strong) TSJavelinAPIAlertManagerLocationReceived locationReceivedBlock;
@property (nonatomic, strong) NSString *alertQueueName;
@property (nonatomic, strong) NSTimer *findActiveAlertTimer;
@property (nonatomic, strong) NSString *remoteHostName;
@property (nonatomic, assign) NSUInteger retryAttempts;

@end

@implementation TSJavelinAlertManager

static TSJavelinAlertManager *_sharedManager = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedManager {
    if (_sharedManager == nil) {
        dispatch_once(&onceToken, ^{
            _sharedManager = [[TSJavelinAlertManager alloc] init];
        });
        _sharedManager.sqs = [AWSSQS defaultSQS];
        
        NSString *accessKey;
        NSString *secretKey;
#ifdef DEV
        accessKey = kTSJavelinAlertManagerSQSDevelopmentAccessKey;
        secretKey = kTSJavelinAlertManagerSQSDevelopmentSecretKey;
        
        _sharedManager.alertQueueName = kTSJavelinAlertManagerSQSDevelopmentAlertQueueName;
        
#elif DEMO
        
        accessKey = kTSJavelinAlertManagerSQSDevelopmentAccessKey;
        secretKey = kTSJavelinAlertManagerSQSDevelopmentSecretKey];
        _sharedManager.alertQueueName = kTSJavelinAlertManagerSQSDemoAlertQueueName;
        
#elif APP_STORE
        
        accessKey = kTSJavelinAlertManagerSQSProductionAccessKey;
        secretKey = kTSJavelinAlertManagerSQSProductionSecretKey;
        
        _sharedManager.alertQueueName = kTSJavelinAlertManagerSQSProductionAlertQueueName;
        
#endif
        AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey
                                                                                                          secretKey:secretKey];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration  alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        
        [AWSSQS registerSQSWithConfiguration:configuration forKey:kTSJavelinAlertManagerSQSKey];
        
        _sharedManager.sqs = [AWSSQS SQSForKey:kTSJavelinAlertManagerSQSKey];
    }
    
    return _sharedManager;
}

#pragma mark - Alert methods

- (void)initiateDirectRestAPIAlert:(TSJavelinAPIAlert *)alert type:(NSString *)type location:(CLLocation *)location completion:(void (^)(TSJavelinAPIAlert *activeAlert, BOOL inside))completion {
    
    if (!alert) {
        return;
    }
    
    if (!type || [type isEqualToString:@""]) {
        type = @"E";
    }
    
    if (![TSJavelinAPIClient sharedClient].isStillActiveAlert) {
        return;
    }
    
    NSMutableDictionary *alertInfo = [[NSMutableDictionary alloc] initWithCapacity:7];
    alertInfo[@"user"] = alert.agencyUser.username;
    
    if ([TSGeofence isWithinBoundariesWithOverhangAndOpen:location agency:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency] || (_activeAlert && _activeAlert.agency.identifier == [TSJavelinAPIClient loggedInUser].agency.identifier)) {
        _activeAlert = alert;
        alertInfo[@"location_accuracy"] = [NSNumber numberWithDouble:location.horizontalAccuracy];
        alertInfo[@"location_altitude"] = [NSNumber numberWithDouble:location.altitude];
        alertInfo[@"location_latitude"] = [NSNumber numberWithDouble:location.coordinate.latitude];
        alertInfo[@"location_longitude"] = [NSNumber numberWithDouble:location.coordinate.longitude];
        alertInfo[@"alert_type"] = type;
        alertInfo[@"agency"] = [NSNumber numberWithInteger:[TSJavelinAPIClient loggedInUser].agency.identifier];
        [[TSJavelinAPIClient sharedClient] sendDirectRestAPIAlertWithParameters:alertInfo completion:^(TSJavelinAPIAlert *activeAlert) {
            if (!activeAlert) {
                [self setActiveAlert:nil];
            }
            
            if (completion) {
                completion(activeAlert, YES);
            }
        }];
    }
    else {
        NSLog(@"Out of bounds or no agency");
        if (completion) {
            completion(nil, NO);
        }
        [self setActiveAlert:nil];
        return;
    }
}

- (void)initiateQueuedAlert:(TSJavelinAPIAlert *)alert type:(NSString *)type location:(CLLocation *)location completion:(TSJavelinAlertManagerAlertQueuedBlock)completion {
    
    if (alert == nil) {
        return;
    }

    if (!type || [type isEqualToString:@""]) {
        type = @"E";
    }
    
    if (![TSJavelinAPIClient sharedClient].isStillActiveAlert) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSMutableDictionary *alertInfo = [[NSMutableDictionary alloc] initWithCapacity:7];
        alertInfo[@"user"] = alert.agencyUser.username;
        
        BOOL inside = NO;
        
        if ([TSGeofence isWithinBoundariesWithOverhangAndOpen:location agency:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency] || (_activeAlert && _activeAlert.agency.identifier == [TSJavelinAPIClient loggedInUser].agency.identifier)) {
            inside = YES;
            
            _activeAlert = alert;
        }
        
        alertInfo[@"location_accuracy"] = [NSNumber numberWithDouble:location.horizontalAccuracy];
        alertInfo[@"location_altitude"] = [NSNumber numberWithDouble:location.altitude];
        alertInfo[@"location_latitude"] = [NSNumber numberWithDouble:location.coordinate.latitude];
        alertInfo[@"location_longitude"] = [NSNumber numberWithDouble:location.coordinate.longitude];
        alertInfo[@"alert_type"] = type;
        alertInfo[@"agency"] = [NSNumber numberWithInteger:[TSJavelinAPIClient loggedInUser].agency.identifier];
        alertInfo[@"alert_initiated_outside"] = [NSNumber numberWithBool:!inside];
        
        NSString *alertJson = [TSJavelinAlertAMQPMessage amqpMessageStringFromDictionary:alertInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        AWSSQSGetQueueUrlRequest *getQueueURLRequest = [[AWSSQSGetQueueUrlRequest alloc] init];
        getQueueURLRequest.queueName = _alertQueueName;
        AWSTask *getQueueUrlTask = [_sqs getQueueUrl:getQueueURLRequest];
        
        [[getQueueUrlTask continueWithBlock:^id(AWSTask *task) {
            if (task.error) {
                NSLog(@"Error: %@", task.error);
                if (completion) {
                    completion(NO, inside);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                });
                return nil;
            }
            
            AWSSQSGetQueueUrlResult *result = task.result;
            AWSSQSSendMessageRequest *sendMessageRequest = [[AWSSQSSendMessageRequest alloc] init];
            sendMessageRequest.queueUrl = result.queueUrl;
            sendMessageRequest.messageBody = alertJson;
            
            return [_sqs sendMessage:sendMessageRequest];
        }] continueWithBlock:^id(AWSTask *task) {
            
            if (task.error) {
                NSLog(@"Error: %@", task.error);
                if (completion) {
                    completion(NO, inside);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                });
                return nil;
            }
            
            if (inside) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTSJavelinAlertManagerSentActiveAlert];
            }
            
            if (completion) {
                completion(YES, inside);
            }
            
            if (inside) {
                _retryAttempts = 0;
                [self scheduleFindActiveAlertTimer];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
            
            if (inside) {
                // Send user profile using API client method
                [[TSJavelinAPIClient sharedClient] uploadUserProfileData:^(BOOL profileDataUploadSucceeded, BOOL imageUploadSucceeded) {
                    if (profileDataUploadSucceeded) {
                        NSLog(@"profileDataUploadSucceeded");
                    }
                    if (imageUploadSucceeded) {
                        NSLog(@"imageUploadSucceeded");
                    }
                }];
            }
            
            
            return nil;
        }];
    });
}

- (void)scheduleFindActiveAlertTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
    _findActiveAlertTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                            target:self
                                                          selector:@selector(findAndSetActiveAlertForLoggedinUser)
                                                          userInfo:nil
                                                           repeats:NO];
    });
}


- (void)findAndSetActiveAlertForLoggedinUser {
    NSLog(@"findACtiveAlertCalled");
    
    if ([TSJavelinAlertManager sharedManager].activeAlert.url) {
        return;
    }
    
    [[TSJavelinAPIClient sharedClient] findActiveAlertForLoggedinUser:^(TSJavelinAPIAlert *activeAlert) {
        if (activeAlert) {
            [[TSJavelinAlertManager sharedManager] setActiveAlert:activeAlert];
        }
        else {
            
            _retryAttempts++;
            
            if (!(_retryAttempts % 2)) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinAlertManagerDidNotFindAlert object:nil];
                if ([_delegate respondsToSelector:@selector(alertManagerDidNotFindAlert:)]) {
                    [_delegate alertManagerDidNotFindAlert:_activeAlert];
                }
            }
            
            [self scheduleFindActiveAlertTimer];
        }
    }];
}

- (void)alertReceiptReceivedForAlertWithURL:(NSString *)url {
    if (_activeAlert) {
        if (!_activeAlert.url) {
            _activeAlert.url = url;
            [self sendActiveAlertNotification];
        }
    }
}

- (void)sendActiveAlertNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinAlertManagerDidReceiveActiveAlertNotification object:_activeAlert];
    if ([_delegate respondsToSelector:@selector(alertManagerDidReceiveAlert:)]) {
        [_delegate alertManagerDidReceiveAlert:_activeAlert];
    }
    [_findActiveAlertTimer invalidate];
    [[TSJavelinAPIClient sharedClient] startChatForActiveAlert];
    [self updateAlertWithCallLength:_activeAlert.callLength completion:nil];
}

- (void)stopAlertUpdates {
    [_findActiveAlertTimer invalidate];
}

- (void)setActiveAlert:(TSJavelinAPIAlert *)activeAlert
{
    if (!activeAlert) {
        TSJavelinAPIAlert *inactiveAlert = _activeAlert;
        _activeAlert = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinAlertManagerDidDisarmNotification object:inactiveAlert];
        
        if ([_delegate respondsToSelector:@selector(alertManagerDidDisarmAlert:)]) {
            [_delegate alertManagerDidDisarmAlert:inactiveAlert];
        }
    }
    
    if (!activeAlert.url) {
        return;
    }
    if (![_activeAlert.url isEqualToString:activeAlert.url]) {
        _activeAlert.url = activeAlert.url;
        [self sendActiveAlertNotification];
    }
}

- (void)resetArchivedAlertBools {
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTSJavelinAlertManagerSentActiveAlert];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTSJavelinAlertManagerAwaitingDisarm];
}

- (void)updateAlertWithCallLength:(NSTimeInterval)length completion:(void (^)(TSJavelinAPIAlert *activeAlert))completion {
    
    _activeAlert.callLength = length;
    
    [[TSJavelinAPIClient sharedClient] updateAlertWithCallLength:length completion:completion];
}


- (void)alertWasCompletedByDispatcher:(NSString *)alertUrl {
    
    if (_activeAlert && [_activeAlert.url isEqualToString:alertUrl]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinAlertManagerDidReceiveAlertCompletion object:_activeAlert];
        
        if ([_delegate respondsToSelector:@selector(dispatcherDidCompleteAlert:)]) {
            [_delegate dispatcherDidCompleteAlert:_activeAlert];
        }
    }
}

@end
