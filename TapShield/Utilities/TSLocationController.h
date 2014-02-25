//
//  TSLocationController.h
//  TapShield
//
//  Created by Adam Share on 2/25/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol TSLocationControllerDelegate

@required
- (void)locationDidUpdate:(CLLocation*)location;

@end

typedef void (^TSLocationControllerLocationReceived)(CLLocation *location);

@interface TSLocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, weak) id <TSLocationControllerDelegate> delegate;

@property (nonatomic, strong) TSLocationControllerLocationReceived locationReceivedBlock;
@property (nonatomic, strong) TSLocationControllerLocationReceived accurateLocationReceivedBlock;

+ (instancetype)sharedLocationController;

- (void)startStandardLocationUpdates:(TSLocationControllerLocationReceived)completion;
- (void)latestLocation:(TSLocationControllerLocationReceived)completion;
- (void)latestAccurateLocation:(TSLocationControllerLocationReceived)completion;

@end
