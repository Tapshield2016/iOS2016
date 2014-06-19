//
//  TSJavelinAPIDispatchCenter.m
//  TapShield
//
//  Created by Adam Share on 6/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIDispatchCenter.h"
#import "TSJavelinAPIClosedDate.h"
#import "TSJavelinAPIPeriod.h"

static NSString *const kModelAgency = @"agency";
static NSString *const kModelClosedDate = @"closed_date";
static NSString *const kModelOpeningHours = @"opening_hours";
static NSString *const kModelName = @"name";
static NSString *const kModelPhoneNumber = @"phone_number";

@implementation TSJavelinAPIDispatchCenter

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    _name = [attributes nonNullObjectForKey:kModelName];
    _phoneNumber = [attributes nonNullObjectForKey:kModelPhoneNumber];
    [self setClosedDates:[attributes nonNullObjectForKey:kModelClosedDate]];
    [self setOpeningHours:[attributes nonNullObjectForKey:kModelOpeningHours]];
    
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _name = [coder decodeObjectForKey:kModelName];
        _phoneNumber = [coder decodeObjectForKey:kModelPhoneNumber];
        _closedDates = [coder decodeObjectForKey:kModelClosedDate];
        _openingHours = [coder decodeObjectForKey:kModelOpeningHours];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_name forKey:kModelName];
    [encoder encodeObject:_phoneNumber forKey:kModelPhoneNumber];
    [encoder encodeObject:_closedDates forKey:kModelClosedDate];
    [encoder encodeObject:_openingHours forKey:kModelOpeningHours];
}


- (void)setOpeningHours:(NSArray *)openingHours {
    
    if (!openingHours) {
        return;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:openingHours.count];
    for (NSDictionary *dictionary in openingHours) {
        TSJavelinAPIPeriod *dispatcherTime = [[TSJavelinAPIPeriod alloc] initWithAttributes:dictionary];
        [mutableArray addObject:dispatcherTime];
    }
    
    _openingHours = mutableArray;
}

- (void)setClosedDates:(NSArray *)closedDates {
    
    if (!closedDates) {
        return;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:closedDates.count];
    for (NSDictionary *dictionary in closedDates) {
        TSJavelinAPIClosedDate *closedDate = [[TSJavelinAPIClosedDate alloc] initWithAttributes:dictionary];
        [mutableArray addObject:closedDate];
    }
    
    _closedDates = mutableArray;
}

- (BOOL)isOpen {
    
    NSDate *now = [NSDate date];
    
    for (TSJavelinAPIClosedDate *date in _closedDates) {
        
        if ([date.startDate isEarlierThanDate:now] && [date.endDate isLaterThanDate:now]) {
            return NO;
        }
    }
    
    if (!_openingHours || !_openingHours.count) {
        return YES;
    }
    
    for (TSJavelinAPIPeriod *period in _openingHours) {
        if (period.day == now.weekday) {
            if ([period.startTime isEarlierThanTimeIgnoringDate:now] &&
                [period.endTime isLaterThanTimeIgnoringDate:now]) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
