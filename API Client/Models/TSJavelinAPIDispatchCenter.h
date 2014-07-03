//
//  TSJavelinAPIDispatchCenter.h
//  TapShield
//
//  Created by Adam Share on 6/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@interface TSJavelinAPIDispatchCenter : TSJavelinAPIBaseModel

//agency
//closed_date
//opening_hours
//name
//phone_number

@property (strong, nonatomic, readonly) NSArray *closedDates;
@property (strong, nonatomic, readonly) NSArray *openingHours;
@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *phoneNumber;

- (BOOL)isOpen;

@end
