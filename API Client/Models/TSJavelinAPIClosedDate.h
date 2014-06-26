//
//  TSJavelinAPIClosedDate.h
//  TapShield
//
//  Created by Adam Share on 6/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@interface TSJavelinAPIClosedDate : TSJavelinAPIBaseModel

//"url": "https://dev.tapshield.com/api/v1/closed-date/1/",
//"dispatch_center": "https://dev.tapshield.com/api/v1/dispatch-center/1/",
//"start_date": "2014-06-30T04:00:00Z",
//"end_date": "2014-08-31T04:00:00Z"

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@end
