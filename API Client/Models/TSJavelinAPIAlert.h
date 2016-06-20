//
//  TSJavelinAPIAlert.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPITimeStampedModel.h"
#import <CoreLocation/CoreLocation.h>

@class TSJavelinAPIAgency;
@class TSJavelinAPIUser;

@interface TSJavelinAPIAlert : TSJavelinAPITimeStampedModel

@property (nonatomic, strong) TSJavelinAPIAgency *agency;
@property (nonatomic, strong) TSJavelinAPIUser *agencyDispatcher;
@property (nonatomic, strong) TSJavelinAPIUser *agencyUser;

@property (nonatomic, strong) NSDate *completedTime;
@property (nonatomic, strong) NSDate *disarmedTime;

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *initiatedBy;
@property (nonatomic, strong) NSString *notes;

@property (nonatomic, assign) NSTimeInterval callLength;
@property (nonatomic, assign) BOOL inBounds;
@property (nonatomic, strong) CLLocation *latestLocation;




@end
