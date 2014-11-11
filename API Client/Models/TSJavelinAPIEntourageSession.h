//
//  TSJavelinAPIEntourageSession.h
//  TapShield
//
//  Created by Adam Share on 11/9/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#import "MKMapItem+EncodeDecode.h"

#define kTRACKING_STATUS_CHOICES @{@"T": "Tracking", @"A": @"Arrived@", @"N": @"Non-Arrival", @"C": @"Cancelled", @"U": @"Unknown"}

@interface TSJavelinAPIEntourageSession : TSJavelinAPIBaseModel

@property (strong, nonatomic) NSString *status;

@property (strong, nonatomic) MKMapItem *startLocation;
@property (strong, nonatomic) MKMapItem *endLocation;

@property (strong, nonatomic) NSDate *eta;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *arrivalTime;

@property (assign, nonatomic) BOOL entourageNotified;

@property (strong, nonatomic) MKPolyline *locations;

@end
