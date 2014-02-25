//
//  TSLocationController.h
//  TapShield
//
//  Created by Adam Share on 2/25/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol TSLocationControllerDelegate
@required

- (void)locationDidUpdate:(CLLocation*)location;

@end

@interface TSLocationController : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *location;
    __weak id delegate;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, weak) id  delegate;

+ (TSLocationController *)sharedLocationController;

@end
