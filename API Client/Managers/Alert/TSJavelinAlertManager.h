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

@class TSJavelinAPIAlert;

typedef void (^TSJavelinAlertManagerAlertQueuedBlock)(BOOL success);

// Delegate definition
@protocol TSJavelinAlertManagerDelegate <NSObject>

@optional
- (void)locationUpdated:(CLLocation *)location;
- (void)locationUpdateFailed:(NSError *)error;
- (void)locationServiceAuthorizationStatusChanged:(CLAuthorizationStatus)status;

@end

typedef void (^TSJavelinAPIAlertManagerLocationReceived)(CLLocation *location);

@interface TSJavelinAlertManager : NSObject <CLLocationManagerDelegate>

@property (weak) id<TSJavelinAlertManagerDelegate> delegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) TSJavelinAPIAlert *activeAlert;

+ (instancetype)sharedManager;

// Location methods
- (void)startStandardLocationUpdates:(CLLocation *)existingLocation completion:(TSJavelinAPIAlertManagerLocationReceived)completion;
- (void)startSignificantChangeUpdates:(TSJavelinAPIAlertManagerLocationReceived)completion;
- (BOOL)locationServicesEnabled;

// Alert methods
- (void)initiateAlert:(TSJavelinAPIAlert *)alert type:(NSString *)type existingLocation:(CLLocation *)existingLocation completion:(TSJavelinAlertManagerAlertQueuedBlock)completion;
- (void)alertReceiptReceivedForAlertWithURL:(NSString *)url;
- (void)cancelAlert;

@end
