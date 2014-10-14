//
//  TSJavelinAlertManager.h
//  Javelin
//
//  Created by Ben Boyd on 10/30/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const TSJavelinAlertManagerDidReceiveActiveAlertNotification;
extern NSString * const TSJavelinAlertManagerDidDisarmNotification;
extern NSString * const TSJavelinAlertManagerDidSendAlertOutsideGeofenceNotification;

extern NSString * const kTSJavelinAlertManagerSentActiveAlert;
extern NSString * const kTSJavelinAlertManagerAwaitingDisarm;
extern NSString * const kTSJavelinAlertManagerDidNotFindAlert;

extern NSString * const TSJavelinAlertManagerDidReceiveAlertCompletion;

@class TSJavelinAPIAlert;

typedef void (^TSJavelinAlertManagerAlertQueuedBlock)(BOOL sent, BOOL inside);
typedef void (^TSJavelinAPIAlertManagerLocationReceived)(CLLocation *location);


@protocol TSJavelinAlertManagerDelegate <NSObject>

@optional
- (void)dispatcherDidCompleteAlert:(TSJavelinAPIAlert *)alert;
- (void)alertManagerDidDisarmAlert:(TSJavelinAPIAlert *)alert;
- (void)alertManagerDidReceiveAlert:(TSJavelinAPIAlert *)alert;
- (void)alertManagerDidNotFindAlert:(TSJavelinAPIAlert *)alert;

@end


@interface TSJavelinAlertManager : NSObject

@property (nonatomic, weak) id <TSJavelinAlertManagerDelegate> delegate;
@property (nonatomic, strong) TSJavelinAPIAlert *activeAlert;

+ (instancetype)sharedManager;

// Alert methods
- (void)initiateDirectRestAPIAlert:(TSJavelinAPIAlert *)alert type:(NSString *)type location:(CLLocation *)location completion:(void (^)(TSJavelinAPIAlert *activeAlert, BOOL inside))completion;
- (void)initiateQueuedAlert:(TSJavelinAPIAlert *)alert type:(NSString *)type location:(CLLocation *)location completion:(TSJavelinAlertManagerAlertQueuedBlock)completion;
- (void)alertReceiptReceivedForAlertWithURL:(NSString *)url;
- (void)stopAlertUpdates;
- (void)resetArchivedAlertBools;

- (void)updateAlertWithCallLength:(NSTimeInterval)length completion:(void (^)(TSJavelinAPIAlert *activeAlert))completion;

- (void)alertWasCompletedByDispatcher:(NSString *)alertUrl;

@end
