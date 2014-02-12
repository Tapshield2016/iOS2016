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
//#import "Reachability.h"
#import <AFNetworkReachabilityManager.h>
#import <MapKit/MapKit.h>
#include <AmazonSQSClient.h>
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

NSString * const TSJavelinAlertManagerDidRecieveActiveAlertNotification = @"TSJavelinAlertManagerDidRecieveActiveAlertNotification";
NSString * const TSJavelinAlertManagerDidCancelNotification = @"TSJavelinAlertManagerDidCancelNotification";
NSString * const TSJavelinAlertManagerDidSendAlertOutsideGeofenceNotification = @"TSJavelinAlertManagerDidSendAlertOutsideGeofenceNotification";

@interface TSJavelinAlertManager ()

@property (nonatomic, strong) AmazonSQSClient *sqs;
@property (nonatomic, assign) CLLocation *lastReportedLocation;
@property (nonatomic, assign) BOOL locationUpdatesInProgress;
@property (nonatomic, strong) TSJavelinAPIAlertManagerLocationReceived locationReceivedBlock;
@property (nonatomic, strong) NSString *alertQueueName;
@property (nonatomic, strong) NSTimer *getActiveAlertTimer;
@property (nonatomic, strong) NSString *remoteHostName;

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
        [_sharedManager initLocationManager];
    }
    
    return _sharedManager;
}

#pragma mark - Location methods

- (void)initLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

- (void)startStandardLocationUpdates:(CLLocation *)existingLocation completion:(TSJavelinAPIAlertManagerLocationReceived)completion {

    NSLog(@"Existing Location - %@", existingLocation);
    
    if (existingLocation) {
        completion(existingLocation);
    }
    else if (completion) {
        _locationReceivedBlock = completion;
    }
    
    if (_locationManager == nil) {
        [self initLocationManager];
    }
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    //_locationManager.distanceFilter = 500; // meters
    
    [_locationManager startUpdatingLocation];
    _locationUpdatesInProgress = YES;

}

- (void)startSignificantChangeUpdates:(TSJavelinAPIAlertManagerLocationReceived)completion {
    if ([CLLocationManager locationServicesEnabled]) {
        if (_locationManager == nil) {
            [self initLocationManager];
        }
        
        if (completion) {
            _locationReceivedBlock = completion;
        }
        
        [_locationManager startMonitoringSignificantLocationChanges];
        _locationUpdatesInProgress = YES;
    }
}

- (void)stopLocationUpdates {
    [_locationManager stopUpdatingLocation];
    _locationUpdatesInProgress = NO;
    
    if (_locationReceivedBlock) {
        _locationReceivedBlock = nil;
    }
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //NSLog(@"%@", locations);
    _lastReportedLocation = [locations lastObject];
    
    if ([_delegate respondsToSelector:@selector(locationUpdated:)]) {
        [_delegate locationUpdated:_lastReportedLocation];
    }
    
    if (_locationReceivedBlock) {
        _locationReceivedBlock(_lastReportedLocation);
        _locationReceivedBlock = nil;
    }
//#warning Geofence Testing
//    [TSLocationGeofenceTestView showDataFromLocation:_lastReportedLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(locationUpdateFailed:)]) {
        [_delegate locationUpdateFailed:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (!(status == kCLAuthorizationStatusAuthorized && _locationUpdatesInProgress)) {
        [self stopLocationUpdates];
    }
    
    if ([_delegate respondsToSelector:@selector(locationServiceAuthorizationStatusChanged:)]) {
        [_delegate locationServiceAuthorizationStatusChanged:status];
    }
}

#pragma mark - Alert methods

- (void)initiateAlert:(TSJavelinAPIAlert *)alert type:(NSString *)type existingLocation:(CLLocation *)existingLocation completion:(TSJavelinAlertManagerAlertQueuedBlock)completion {
    
    if (alert == nil) {
        return;
    }

    if (!type || [type isEqualToString:@""]) {
        type = @"E";
    }

    _activeAlert = alert;
    
    [self startStandardLocationUpdates:existingLocation completion:^(CLLocation *location) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
            NSMutableDictionary *alertInfo = [[NSMutableDictionary alloc] initWithCapacity:4];
            alertInfo[@"user"] = alert.agencyUser.email;
            
            if ([TSGeofence isWithinBoundariesWithOverhang:location]) {
                alertInfo[@"location_accuracy"] = [NSNumber numberWithDouble:location.horizontalAccuracy];
                alertInfo[@"location_altitude"] = [NSNumber numberWithDouble:location.altitude];
                alertInfo[@"location_latitude"] = [NSNumber numberWithDouble:location.coordinate.latitude];
                alertInfo[@"location_longitude"] = [NSNumber numberWithDouble:location.coordinate.longitude];
                alertInfo[@"alert_type"] = type;
            }
            else {
                return;
            }

            NSString *alertJson = [TSJavelinAlertAMQPMessage amqpMessageStringFromDictionary:alertInfo];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });
            
            SQSGetQueueUrlRequest *getQueueURLRequest = [[SQSGetQueueUrlRequest alloc] initWithQueueName:_alertQueueName];

            AFNetworkReachabilityManager *hostReachability = [AFNetworkReachabilityManager managerForDomain:TSJavelinAlertManagerRemoteHostName];
            if ([hostReachability networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
                if (completion) {
                    NSLog(@"Lost Connectivity During Initiate Alert");
                    completion(NO);
                    return;
                }
            }
            
            SQSGetQueueUrlResponse *getQueueURLResponse = [_sqs getQueueUrl:getQueueURLRequest];
            SQSSendMessageRequest *sendMessageRequest = [[SQSSendMessageRequest alloc] initWithQueueUrl:getQueueURLResponse.queueUrl
                                                                                         andMessageBody:alertJson];
            
            hostReachability = [AFNetworkReachabilityManager managerForDomain:TSJavelinAlertManagerRemoteHostName];
            if ([hostReachability networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
                if (completion) {
                    NSLog(@"Lost Connectivity During Initiate Alert");
                    completion(NO);
                    return;
                }
            }
            
            SQSSendMessageResponse *sendMessageResponse = [_sqs sendMessage:sendMessageRequest];
            
            if(sendMessageResponse.error != nil) {
                NSLog(@"Error: %@", sendMessageResponse.error);
                if (completion) {
                    completion(NO);
                }
            }
            else {
                if (completion) {
                    completion(YES);
                    [self scheduleTimerForLoggedInUser];
                }
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
    }];
}

- (void)scheduleTimerForLoggedInUser {
    dispatch_async(dispatch_get_main_queue(), ^{
    _getActiveAlertTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                            target:self
                                                          selector:@selector(findActiveAlertForLoggedinUser)
                                                          userInfo:nil
                                                           repeats:NO];
    });
}


- (void)findActiveAlertForLoggedinUser {
    NSLog(@"findACtiveAlertCalled");
    [[TSJavelinAPIClient sharedClient] findActiveAlertForLoggedinUser:^(BOOL success) {
        if (!success) {
            [self scheduleTimerForLoggedInUser];
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
    [_getActiveAlertTimer invalidate];
    [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinAlertManagerDidRecieveActiveAlertNotification object:_activeAlert];
}

- (void)cancelAlert {
    [_getActiveAlertTimer invalidate];
    [self stopLocationUpdates];
}

- (void)setActiveAlert:(TSJavelinAPIAlert *)activeAlert
{
    if (!activeAlert) {
        _activeAlert = nil;
    }
    
    if (!activeAlert.url) {
        return;
    }
    if (![_activeAlert.url isEqualToString:activeAlert.url]) {
        _activeAlert = activeAlert;
        [self sendActiveAlertNotification];
    }
}




@end
