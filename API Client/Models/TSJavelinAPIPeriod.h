//
//  TSJavelinAPIDispatcherTimes.h
//  TapShield
//
//  Created by Adam Share on 6/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@interface TSJavelinAPIPeriod : TSJavelinAPIBaseModel

//"url": "https://dev.tapshield.com/api/v1/dispatcher-times/11/",
//"dispatch_center": "https://dev.tapshield.com/api/v1/dispatch-center/4/",
//"day": "2",
//"start_time": "08:00:00",
//"end_time": "16:30:00"

@property (assign, nonatomic) NSUInteger day;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;

@end
