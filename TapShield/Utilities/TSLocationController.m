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
    }
    return self;
}

#pragma mark - Location Methods

- (void)startStandardLocationUpdates:(TSLocationControllerLocationReceived)completion {
    
    if (_location) {
        completion(_location);
    }
    else if (completion) {
        _locationReceivedBlock = completion;
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
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    if ([_delegate respondsToSelector:@selector(didStartMonitoringForRegion:)]) {
        [_delegate didStartMonitoringForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([_delegate respondsToSelector:@selector(didEnterRegion:)]) {
        [_delegate didEnterRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([_delegate respondsToSelector:@selector(didExitRegion:)]) {
        [_delegate didExitRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if ([_delegate respondsToSelector:@selector(didUpdateHeading:)]) {
        [_delegate didUpdateHeading:newHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(didFailWithError:)]) {
        [_delegate didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
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
