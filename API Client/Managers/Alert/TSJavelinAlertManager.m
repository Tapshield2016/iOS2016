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
#import <AmazonSQSClient.h>
#import <AmazonEndpoints.h>

static NSString * const kTSJavelinAlertManagerSQSDevelopmentAccessKey = @"AKIAJSDRUWW6PPF2FWWA";
static NSString * const kTSJavelinAlertManagerSQSDevelopmentSecretKey = @"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";
static NSString * const kTSJavelinAlertManagerSQSDevelopmentAlertQueueName = @"alert_queue_dev";

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

@property (nonatomic, strong) AmazonSQSClient *sqs;
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
#ifdef DEV
        _sharedManager.sqs = [[AmazonSQSClient alloc] initWithAccessKey:kTSJavelinAlertManagerSQSDevelopmentAccessKey
                                                          withSecretKey:kTSJavelinAlertManagerSQSDevelopmentSecretKey];
        _sharedManager.alertQueueName = kTSJavelinAlertManagerSQSDevelopmentAlertQueueName;
        _sharedManager.sqs.endpoint = [AmazonEndpoints sqsEndpoint:US_EAST_1];
#elif DEMO
        _sharedManager.sqs = [[AmazonSQSClient alloc] initWithAccessKey:kTSJavelinAlertManagerSQSDevelopmentAccessKey
                                                          withSecretKey:kTSJavelinAlertManagerSQSDevelopmentSecretKey];
        _sharedManager.alertQueueName = kTSJavelinAlertManagerSQSDemoAlertQueueName;
        _sharedManager.sqs.endpoint = [AmazonEndpoints sqsEndpoint:US_EAST_1];
#elif APP_STORE
        _sharedManager.sqs = [[AmazonSQSClient alloc] initWithAccessKey:kTSJavelinAlertManagerSQSProductionAccessKey
                                                          withSecretKey:kTSJavelinAlertManagerSQSProductionSecretKey];
        _sharedManager.alertQueueName = kTSJavelinAlertManagerSQSProductionAlertQueueName;
        _sharedManager.sqs.endpoint = [AmazonEndpoints sqsEndpoint:US_EAST_1];
#endif
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
        
        if ([TSGeofence isWithinBoundariesWithOverhangAndOpen:location agency:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency] || (_activeAlert && _activeAlert.agency.identifier == [TSJavelinAPIClient loggedInUser].agency.identifier)) {
            
            _activeAlert = alert;
            
            alertInfo[@"location_accuracy"] = [NSNumber numberWithDouble:location.horizontalAccuracy];
            alertInfo[@"location_altitude"] = [NSNumber numberWithDouble:location.altitude];
            alertInfo[@"location_latitude"] = [NSNumber numberWithDouble:location.coordinate.latitude];
            alertInfo[@"location_longitude"] = [NSNumber numberWithDouble:location.coordinate.longitude];
            alertInfo[@"alert_type"] = type;
            alertInfo[@"agency"] = [NSNumber numberWithInteger:[TSJavelinAPIClient loggedInUser].agency.identifier];
        }
        else {
            NSLog(@"Out of bounds or no agency");
            if (completion) {
                completion(NO, NO);
            }
            [self setActiveAlert:nil];
            return;
        }
        
        NSString *alertJson = [TSJavelinAlertAMQPMessage amqpMessageStringFromDictionary:alertInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        SQSGetQueueUrlRequest *getQueueURLRequest = [[SQSGetQueueUrlRequest alloc] initWithQueueName:_alertQueueName];
        SQSGetQueueUrlResponse *getQueueURLResponse = [_sqs getQueueUrl:getQueueURLRequest];
        
        if (getQueueURLResponse.error != nil) {
            NSLog(@"Error: %@", getQueueURLResponse.error);
            if (completion) {
                completion(NO, YES);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
            return;
        }
        
        SQSSendMessageRequest *sendMessageRequest = [[SQSSendMessageRequest alloc] initWithQueueUrl:getQueueURLResponse.queueUrl
                                                                                     andMessageBody:alertJson];
        SQSSendMessageResponse *sendMessageResponse = [_sqs sendMessage:sendMessageRequest];

        if (sendMessageResponse.error != nil) {
            NSLog(@"Error: %@", sendMessageResponse.error);
            if (completion) {
                completion(NO, YES);
            }
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTSJavelinAlertManagerSentActiveAlert];
            
            if (completion) {
                completion(YES, YES);
            }
            
            _retryAttempts = 0;
            [self scheduleFindActiveAlertTimer];
            
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
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
            _activeAlert.url = [NSString stringWithFormat:@"%@://%@%@", [[TSJavelinAPIClient sharedClient] baseURL].scheme, [[TSJavelinAPIClient sharedClient] baseURL].host, url];
            [self sendActiveAlertNotification];
        }
        NSLog(@"_activeAlert.url: %@", _activeAlert.url);
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


- (void)alertWasCompletedByDispatcher {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinAlertManagerDidReceiveAlertCompletion object:_activeAlert];
    
    if ([_delegate respondsToSelector:@selector(dispatcherDidCompleteAlert:)]) {
        [_delegate dispatcherDidCompleteAlert:_activeAlert];
    }
}

@end
