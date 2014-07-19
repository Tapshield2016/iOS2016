//
//  TSLocationController.m
//  TapShield
//
//  Created by Adam Share on 2/25/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#define GOOD_ACCURACY 200
#define MAX_SECONDS 200

#import "TSLocationController.h"
#import "TSAlertManager.h"

@interface TSLocationController ()

@property (nonatomic, strong) NSTimer *cycleTimer;

@end

@implementation TSLocationController

static TSLocationController *_sharedLocationControllerInstance = nil;
static dispatch_once_t predicate;

+ (instancetype)sharedLocationController {
    
    if (_sharedLocationControllerInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedLocationControllerInstance = [[self alloc] init];
        });
    }
    return _sharedLocationControllerInstance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 1.0;
        self.geofence = [[TSGeofence alloc] init];
        
        UIDevice *device = [UIDevice currentDevice];
        device.batteryMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryChanged:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification
                                                   object:device];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryChanged:)
                                                     name:UIDeviceBatteryStateDidChangeNotification
                                                   object:device];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark - Battery Management

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(enterLowPowerState)
                                               object:nil];
    
    [self bestAccuracyForBattery];
}

- (void)batteryChanged:(NSNotification *)notification {
    
    [self bestAccuracyForBattery];
}

#pragma mark - Region Methods

- (void)startMonitoringForRegion:(CLRegion *)region {
    
    [_locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringForRegion:(CLRegion *)region {
    
    [_locationManager stopMonitoringForRegion:region];
}

- (void)stopMonitoringAllRegions {
    
    for (CLRegion *region in _locationManager.monitoredRegions) {
        [_locationManager stopMonitoringForRegion:region];
    }
}

- (void)requestStateForRegion:(CLRegion *)region {
    
    [_locationManager requestStateForRegion:region];
}


#pragma mark - Location Methods

- (void)startStandardLocationUpdates:(TSLocationControllerLocationReceived)completion {
    
    
    if (completion) {
        if (_location) {
            completion(_location);
        }
        else {
            _locationReceivedBlock = completion;
        }
    }
    
    [_locationManager startUpdatingLocation];
}

- (void)startSignificantChangeUpdates:(TSLocationControllerLocationReceived)completion {
  
    if (completion) {
        _locationReceivedBlock = completion;
    }
        
    [_locationManager startMonitoringSignificantLocationChanges];
}


- (void)latestLocation:(TSLocationControllerLocationReceived)completion {
    
    if ([[NSDate date] timeIntervalSinceDate:_location.timestamp] < MAX_SECONDS) {
        completion(_location);
        return;
    }
    else if (completion) {
        _locationReceivedBlock = completion;
    }
    
    [_locationManager startUpdatingLocation];
}

- (void)latestAccurateLocation:(TSLocationControllerLocationReceived)completion {
    
    if (_location.horizontalAccuracy <= GOOD_ACCURACY) {
        completion(_location);
        return;
    }
    else if (completion) {
        _accurateLocationReceivedBlock = completion;
    }
    
    [_locationManager startUpdatingLocation];
}

- (void)stopLocationUpdates {
    [_locationManager stopUpdatingLocation];
    
    if (_locationReceivedBlock) {
        _locationReceivedBlock = nil;
    }
}

#pragma mark - GPS Strength

- (void)cycleGPSSignalStrengthUntilDate:(NSDate *)date {
    
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];
    
    if (timeInterval < 120) {
        return;
    }
    
    [self scheduleStrengthCycleTimer:timeInterval/2];
    
    [self enterLowPowerState];
}

- (void)scheduleStrengthCycleTimer:(NSTimeInterval)timeInterval {
    
    [self timerReset];
    
    if (!_cycleTimer) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _cycleTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                           target:self
                                                         selector:@selector(timerFired:)
                                                         userInfo:nil
                                                          repeats:NO];
            _cycleTimer.tolerance = 5;
        }];
    }
}

- (void)timerReset {
    [_cycleTimer invalidate];
    _cycleTimer = nil;
}

- (void)timerFired:(NSTimer *)timer {
    
    [self bestAccuracy];
    
    if (timer.timeInterval/2 < 60) {
        return;
    }
    
    [self scheduleStrengthCycleTimer:timer.timeInterval/2];
    
    [self performSelector:@selector(enterLowPowerState) withObject:nil afterDelay:15.0];
}

- (void)bestAccuracyRefresh {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self bestAccuracy];
    
    [_locationManager startUpdatingLocation];
    
    if (![TSAlertManager sharedManager].isAlertInProgress &&
        ![TSAlertManager sharedManager].countdownTimer) {
        [self performSelector:@selector(bestAccuracyForBattery)
                   withObject:nil
                   afterDelay:20];
    }
}

- (void)enterLowPowerState {
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
}

- (void)navigationAccuracy {
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
}

- (void)tenMetersAccuracy {
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
}

- (void)bestAccuracy {
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

- (void)hundredMetersAccuracy {
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
}

- (void)bestAccuracyForAlert {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self bestAccuracy];
}

- (void)bestAccuracyForBattery {
    
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    
    NSLog(@"State: %i Charge: %f", batteryState, batteryLevel);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    
    if (batteryState == UIDeviceBatteryStateCharging) {
        [self navigationAccuracy];
        return;
    }
    
    if (batteryLevel > .20 || [TSAlertManager sharedManager].countdownTimer) {
        [self bestAccuracy];
    }
    else if (batteryLevel > .10) {
        [self tenMetersAccuracy];
    }
    else {
        [self hundredMetersAccuracy];
    }
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    _location  = [locations lastObject];
    
    if (_accurateLocationReceivedBlock) {
        if (_location.horizontalAccuracy <= GOOD_ACCURACY) {
            _accurateLocationReceivedBlock(_location);
            _accurateLocationReceivedBlock = nil;
        }
    }
    
    if (_locationReceivedBlock) {
        _locationReceivedBlock(_location);
        _locationReceivedBlock = nil;
    }
    
    [[TSJavelinAPIClient sharedClient] locationUpdated:_location];
    
    if ([_delegate respondsToSelector:@selector(locationDidUpdate:)]) {
        [_delegate locationDidUpdate:_location];
    }
    
    [_geofence updateProximityToAgencies:_location];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    if ([_delegate respondsToSelector:@selector(didStartMonitoringForRegion:)]) {
        [_delegate didStartMonitoringForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"didEnterRegion %@ - %@", region.identifier, region.description);
    
    if ([_delegate respondsToSelector:@selector(didEnterRegion:)]) {
        [_delegate didEnterRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([_delegate respondsToSelector:@selector(didExitRegion:)]) {
        [_delegate didExitRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if ([_delegate respondsToSelector:@selector(didUpdateHeading:)]) {
        [_delegate didUpdateHeading:newHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
    
    if ([_delegate respondsToSelector:@selector(didFailWithError:)]) {
        [_delegate didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
    
    if ([_delegate respondsToSelector:@selector(monitoringDidFailForRegion:withError:)]) {
        [_delegate monitoringDidFailForRegion:region withError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if ([_delegate respondsToSelector:@selector(didChangeAuthorizationStatus:)]) {
        [_delegate didChangeAuthorizationStatus:status];
    }
}


@end
