//
//  TSJavelinAlertManager.h
//  Javelin
//
//  Created by Ben Boyd on 10/30/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const TSJavelinAlertManagerDidRecieveActiveAlertNotification;
extern NSString * const TSJavelinAlertManagerDidCancelNotification;
extern NSString * const TSJavelinAlertManagerDidSendAlertOutsideGeofenceNotification;

extern NSString * const kTSJavelinAlertManagerSentActiveAlert;
extern NSString * const kTSJavelinAlertManagerAwaitingDisarm;

@class TSJavelinAPIAlert;

typedef void (^TSJavelinAlertManagerAlertQueuedBlock)(BOOL success);
typedef void (^TSJavelinAPIAlertManagerLocationReceived)(CLLocation *location);

@interface TSJavelinAlertManager : NSObject

@property (nonatomic, strong) TSJavelinAPIAlert *activeAlert;

+ (instancetype)sharedManager;

// Alert methods
- (void)initiateAlert:(TSJavelinAPIAlert *)alert type:(NSString *)type location:(CLLocation *)location completion:(TSJavelinAlertManagerAlertQueuedBlock)completion;
- (void)alertReceiptReceivedForAlertWithURL:(NSString *)url;
- (void)stopAlertUpdates;
- (void)resetArchivedAlertBools;

@end
