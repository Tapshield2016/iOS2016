//
//  TSLocationController.h
//  TapShield
//
//  Created by Adam Share on 2/25/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TSJavelinAPIClient.h"
#import "TSGeofence.h"

@protocol TSLocationControllerDelegate <NSObject>

@optional
- (void)locationDidUpdate:(CLLocation*)location;
- (void)didStartMonitoringForRegion:(CLRegion *)region;
- (void)didEnterRegion:(CLRegion *)region;
- (void)didExitRegion:(CLRegion *)region;
- (void)didUpdateHeading:(CLHeading *)newHeading;
- (void)didFailWithError:(NSError *)error;
- (void)monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;
- (void)didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end

typedef void (^TSLocationControllerLocationReceived)(CLLocation *location);

@interface TSLocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) TSGeofence *geofence;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, weak) id <TSLocationControllerDelegate> delegate;

@property (nonatomic, strong) TSLocationControllerLocationReceived locationReceivedBlock;
@property (nonatomic, strong) TSLocationControllerLocationReceived accurateLocationReceivedBlock;

+ (instancetype)sharedLocationController;

- (void)startStandardLocationUpdates:(TSLocationControllerLocationReceived)completion;
- (void)startSignificantChangeUpdates:(TSLocationControllerLocationReceived)completion;
- (void)latestLocation:(TSLocationControllerLocationReceived)completion;

- (void)stopMonitoringSignificantLocationChanges;

- (void)startMonitoringForRegion:(CLRegion *)region;
- (void)stopMonitoringForRegion:(CLRegion *)region;
- (void)stopMonitoringAllRegions;
- (void)requestStateForRegion:(CLRegion *)region;

- (void)stopLocationUpdates;
- (void)cycleGPSSignalStrengthUntilDate:(NSDate *)date;
- (void)bestAccuracyForAlert;
- (void)bestAccuracyForBattery;
- (void)bestAccuracyRefresh;
- (void)enterLowPowerState;

+ (void)driving;
+ (void)walking;

- (void)geocodeAddressString:(NSString *)address completion:(void(^)(NSString *street, NSString *cityStateZip))completion;
- (void)geocodeAddressString:(NSString *)address dictionaryCompletion:(void(^)(NSDictionary *addressDictionary))completion;

@end
