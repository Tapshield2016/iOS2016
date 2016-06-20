//
//  NSDate+Extensions.m
//  TapShield
//
//  Created by Adam Share on 5/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "NSDate+Utilities.h"
//#import "NSDateFormatter+NclusiveAdditions.h"

@implementation NSDateFormatter (NclusiveAdditions)

+ (NSDateFormatter *)sharedInstance
{
    static dispatch_once_t pred;
    static __strong NSDateFormatter *sharedDateFormatter = nil;
    
    dispatch_once(&pred, ^{
        sharedDateFormatter = [[NSDateFormatter alloc] init];
    });
    
    return sharedDateFormatter;
}

- (NSDate *)dateFromString:(NSString *)string format:(NSString *)format
{
    self.dateFormat = format;
    
    return [self dateFromString:string];
}

- (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format
{
    self.dateFormat = format;
    
    return [self stringFromDate:date];
}

- (NSDate *)changeDateFormat:(NSDate *)date currentFormat:(NSString *)currentFormat newFormat:(NSString *)newFormat
{
    NSString *dateString = [[NSDateFormatter sharedInstance] stringFromDate:date format:currentFormat];
    
    return [[NSDateFormatter sharedInstance] dateFromString:dateString format:newFormat];
}

- (NSString *)changeDateStringFormat:(NSString *)dateString currentFormat:(NSString *)currentFormat newFormat:(NSString *)newFormat
{
    NSDate *date = [[NSDateFormatter sharedInstance] dateFromString:dateString format:currentFormat];
    
    return [[NSDateFormatter sharedInstance] stringFromDate:date format:newFormat];
}

@end


static const unsigned componentFlags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal);

@implementation NSDate (Utilities)

// Courtesy of Lukasz Margielewski
+ (NSCalendar *)currentCalendar
{
    static dispatch_once_t pred;
    static __strong NSCalendar *sharedCalendar = nil;
    
    dispatch_once(&pred, ^{
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    
    return sharedCalendar;
}

#pragma mark - Relative Dates

+ (NSDate *)dateWithDaysFromNow:(NSInteger)days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *)dateWithDaysBeforeNow:(NSInteger)days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *)dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *)dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *)dateWithHoursFromNow:(NSInteger)dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark - String Properties
- (NSString *)stringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    return [formatter stringFromDate:self];
}

- (NSString *)shortString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortDateString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)shortDateTimeString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortRelativeDateTimeString
{
    return [self relativeDateTimeWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)mediumString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
}

- (NSString *)mediumTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
}

- (NSString *)mediumDateTimeString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
}

- (NSString *)mediumDateString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)mediumRelativeDateTimeString
{
    return [self relativeDateTimeWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)longString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
}

- (NSString *)longTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle];
}

- (NSString *)longDateTimeString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
}

- (NSString *)longDateString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}


- (NSString *)longRelativeDateTimeString
{
    return [self relativeDateTimeWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)relativeDateTimeWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    
    if (self.isToday) {
        return [NSString stringWithFormat:@"Today %@", [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:timeStyle]];
    }
    else if (self.isTomorrow) {
        return [NSString stringWithFormat:@"Tomorrow %@", [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:timeStyle]];
    }
    else if (self.isYesterday) {
        return [NSString stringWithFormat:@"Yesterday %@", [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:timeStyle]];
    }
    else if (self.isThisWeek && self.isInFuture) {
        return [NSString stringWithFormat:@"%@ %@", [NSDate longStringFromWeekday:self.weekday], [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:timeStyle]];
    }
    return [self stringWithDateStyle:dateStyle timeStyle:timeStyle];
}

- (NSString *)fullDateString
{
    NSString *longDate = [self longDateString];
    
    NSString *weeday = [[NSDate longStringFromWeekday:self.weekday] stringByAppendingString:@" "];
    
    longDate = [weeday stringByAppendingString:longDate];
    
    if (self.isToday)
    {
        longDate = [@"Today - " stringByAppendingString:longDate];
    }
    else if (self.isYesterday)
    {
        longDate = [@"Yesterday - " stringByAppendingString:longDate];
    }
    else if (self.isTomorrow)
    {
        longDate = [@"Tomorrow - " stringByAppendingString:longDate];
    }
    
    return longDate;
}

- (NSString *)relativeMonthWeekString {
    
    NSMutableString *string = [[NSDate longStringFromMonth:self.month] mutableCopy];
    [string appendString:[NSString stringWithFormat:@" %li - %li", (long)self.day, (long)self.day + 6]];
    
    if (self.isThisWeek) {
        [string appendString:@" (this week)"];
    }
    return string;
}

- (NSString *)monthAndYearString {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    if (self.isThisYear) {
        [dateFormat setDateFormat:@"MMMM"];
    }
    else {
        [dateFormat setDateFormat:@"MMMM YYYY"];
    }
    return [dateFormat stringFromDate:self];
}

- (NSString *)monthAndYearExpirationString {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/YYYY"];
    return [dateFormat stringFromDate:self];
}

- (NSString *)monthAndYearShortExpirationString {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/YY"];
    return [dateFormat stringFromDate:self];
}

- (NSString *)iso8601String
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return [dateFormatter stringFromDate:self];
}

+ (NSString *)fileDateTimeNowString
{
    // return a formatted string for a file name
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"ddMMMYY_hhmmssa";
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (NSDate *)dateIgnoringTime
{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    return [[NSDate currentCalendar] dateFromComponents:components];
}

#pragma mark - Comparing Dates

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:componentFlags fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL)isEarlierThanTimeIgnoringDate:(NSDate *)aDate
{
    NSDate *date1 = [self resetDateKeepTime];
    NSDate *date2 = [aDate resetDateKeepTime];
    
    return [date1 isEarlierThanDate:date2];
}

- (BOOL)isLaterThanTimeIgnoringDate:(NSDate *)aDate
{
    NSDate *date1 = [self resetDateKeepTime];
    NSDate *date2 = [aDate resetDateKeepTime];
    
    return [date1 isLaterThanDate:date2];
}

- (BOOL)isToday
{
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)isTomorrow
{
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL)isYesterday
{
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL)isSameWeekAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:componentFlags fromDate:aDate];
    
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.weekOfYear != components2.weekOfYear)
        return NO;
    
    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL)isThisWeek
{
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL)isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

- (BOOL)isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL)isSameMonthAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL)isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

// Thanks Marcin Krzyzanowski, also for adding/subtracting years and months
- (BOOL)isLastMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateBySubtractingMonths:1]];
}

- (BOOL)isNextMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateByAddingMonths:1]];
}

- (BOOL)isSameYearAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL)isThisYear
{
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL)isNextYear
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return (components1.year == (components2.year + 1));
}

- (BOOL)isLastYear
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return (components1.year == (components2.year - 1));
}

- (BOOL)isEarlierThanDate:(NSDate *)aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL)isLaterThanDate:(NSDate *)aDate
{
    return ([self compare:aDate] == NSOrderedDescending);
}

- (BOOL)isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}

- (BOOL)isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}

#pragma mark - Roles
- (BOOL)isTypicallyWeekend
{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL)isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

#pragma mark - Adjusting Dates

// Thaks, rsjohnson
- (NSDate *)dateByAddingYears:(NSInteger)dYears
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:dYears];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)dateBySubtractingYears:(NSInteger)dYears
{
    return [self dateByAddingYears:-dYears];
}

- (NSDate *)dateByAddingMonths:(NSInteger)dMonths
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:dMonths];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)dateBySubtractingMonths:(NSInteger)dMonths
{
    return [self dateByAddingMonths:-dMonths];
}

// Courtesy of dedan who mentions issues with Daylight Savings
- (NSDate *)dateByAddingDays:(NSInteger)dDays
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dDays];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)dateBySubtractingDays:(NSInteger)dDays
{
    return [self dateByAddingDays:(dDays * -1)];
}

- (NSDate *)dateByAddingHours:(NSInteger)dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingHours:(NSInteger)dHours
{
    return [self dateByAddingHours:(dHours * -1)];
}

- (NSDate *)dateByAddingMinutes:(NSInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingMinutes:(NSInteger)dMinutes
{
    return [self dateByAddingMinutes:(dMinutes * -1)];
}

- (NSDateComponents *)componentsWithOffsetFromDate:(NSDate *)aDate
{
    NSDateComponents *dTime = [[NSDate currentCalendar] components:componentFlags fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark - Extremes

- (NSDate *)dateAtStartOfMonth
{
    NSDateComponents *components = [[NSDate currentCalendar] components: NSCalendarUnitMonth | NSCalendarUnitYear
                                                               fromDate:self];
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSDate *)dateAtStartOfWeek
{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear
                                                               fromDate:self];
    components.weekday = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSDate *)dateAtStartOfDay
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

// Thanks gsempe & mteece
- (NSDate *)dateAtEndOfDay
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    components.hour = 11;
    components.minute = 59;
    components.second = 59;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

#pragma mark - Retrieving Intervals

- (NSInteger)minutesAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / D_MINUTE);
}

- (NSInteger)minutesBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger)(ti / D_MINUTE);
}

- (NSInteger)hoursAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / D_HOUR);
}

- (NSInteger)hoursBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger)(ti / D_HOUR);
}

- (NSInteger)daysAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / D_DAY);
}

- (NSInteger)daysBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger)(ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:self toDate:anotherDate options:0];
    return components.day;
}

+ (NSInteger)daysInMonth:(NSInteger)month
{
    NSCalendar *cal = [NSDate currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setMonth:month];
    [comps setYear:2008];
    
    NSRange range = [cal rangeOfUnit:NSCalendarUnitDay
                              inUnit:NSCalendarUnitMonth
                             forDate:[cal dateFromComponents:comps]];
    return range.length;
}

#pragma mark - Decomposing Dates

- (NSInteger)nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitHour fromDate:newDate];
    return components.hour;
}

- (NSInteger)hour
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.hour;
}

- (NSInteger)minute
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.minute;
}

- (NSInteger)seconds
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.second;
}

- (NSInteger)day
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.day;
}

- (NSInteger)month
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.month;
}

- (NSInteger)week
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.weekOfYear;
}

- (NSInteger)weekday
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.weekday;
}

- (NSInteger)nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger)year
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.year;
}

- (NSDate *)resetDateKeepTime
{
    NSDate *now = [NSDate date];
    NSDateComponents *components = [[NSDate currentCalendar] components:
                                    NSCalendarUnitYear |
                                    NSCalendarUnitMonth |
                                    NSCalendarUnitDay
                                                               fromDate:now];
    [components setHour:self.hour];
    [components setMinute:self.minute];
    [components setSecond:self.seconds];
    return [[NSDate currentCalendar] dateFromComponents:components];
}

+ (NSDate *)nextWeekday:(NSInteger)day
{
    NSDate *today = [NSDate date];
    NSDateComponents *nowComponents = [[NSDate currentCalendar] components:
                                       NSCalendarUnitYear |
                                       NSCalendarUnitWeekOfYear |
                                       NSCalendarUnitHour |
                                       NSCalendarUnitMinute |
                                       NSCalendarUnitSecond
                                                                  fromDate:today];
    
    [nowComponents setWeekday:day];
    [nowComponents setWeekOfYear:[nowComponents weekOfYear]];
    [nowComponents setHour:0];
    [nowComponents setMinute:0];
    [nowComponents setSecond:0];
    
    NSDate *weekday = [[NSDate currentCalendar] dateFromComponents:nowComponents];
    
    if (weekday.isInPast && !weekday.isToday)
    {
        [nowComponents setWeekOfYear:[nowComponents weekOfYear] + 1];
        weekday = [[NSDate currentCalendar] dateFromComponents:nowComponents];
    }
    
    return weekday;
}

- (NSDate *)dateWithTime:(NSDate *)dateTime
{
    NSDateComponents *components = [[NSDate currentCalendar] components:
                                    NSCalendarUnitYear |
                                    NSCalendarUnitMonth |
                                    NSCalendarUnitDay
                                                               fromDate:self];
    [components setHour:dateTime.hour];
    [components setMinute:dateTime.minute];
    [components setSecond:dateTime.seconds];
    return [[NSDate currentCalendar] dateFromComponents:components];
}

+ (NSDate *)dateWithISO8061Format:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateFormat:kISO8061DateFormat];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

+ (NSDate *)parsedDateFromISO8601String:(NSString *)iso8601 {
    // Return nil if nil is given
    if (!iso8601 || [iso8601 isEqual:[NSNull null]]) {
        return nil;
    }
    
    // Parse number
    if ([iso8601 isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)iso8601 doubleValue]];
    }
    
    // Parse string
    else if ([iso8601 isKindOfClass:[NSString class]]) {
        const char *str = [iso8601 cStringUsingEncoding:NSUTF8StringEncoding];
        size_t len = strlen(str);
        if (len == 0) {
            return nil;
        }
        
        struct tm tm;
        char newStr[25] = "";
        BOOL hasTimezone = NO;
        
        // 2014-03-30T09:13:00Z
        if (len == 20 && str[len - 1] == 'Z') {
            strncpy(newStr, str, len - 1);
        }
        
        // 2014-03-30T09:13:00-07:00
        else if (len == 25 && str[22] == ':') {
            strncpy(newStr, str, 19);
            hasTimezone = YES;
        }
        
        // 2014-03-30T09:13:00.000Z
        else if (len == 24 && str[len - 1] == 'Z') {
            strncpy(newStr, str, 19);
        }
        
        // 2014-03-30T09:13:00.000-07:00
        else if (len == 29 && str[26] == ':') {
            strncpy(newStr, str, 19);
            hasTimezone = YES;
        }
        
        // Poorly formatted timezone
        else {
            strncpy(newStr, str, len > 24 ? 24 : len);
        }
        
        // Timezone
        size_t l = strlen(newStr);
        if (hasTimezone) {
            strncpy(newStr + l, str + len - 6, 3);
            strncpy(newStr + l + 3, str + len - 2, 2);
        } else {
            strncpy(newStr + l, "+0000", 5);
        }
        
        // Add null terminator
        newStr[sizeof(newStr) - 1] = 0;
        
        if (strptime(newStr, "%FT%T%z", &tm) == NULL) {
            return nil;
        }
        
        time_t t;
        t = mktime(&tm);
        
        return [NSDate dateWithTimeIntervalSince1970:t];
    }
    
    NSAssert1(NO, @"Failed to parse date: %@", iso8601);
    return nil;
}

+ (NSDate *)dateWithISO8601Format:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    
    NSString *dateFormat = kISO8601DateFormat;
    
    if (dateString.length > 25) {
        dateFormat = kISO8601DecimalDateFormat;
    }
    
    [dateFormatter setDateFormat:dateFormat];
    NSDate *date = [dateFormatter dateFromString:dateString];
    if (!date) {
        date = [self parsedDateFromISO8601String:dateString];
    }
    return date;
}

+ (NSDate *)dateFromShortDateString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    
    return [dateFormatter dateFromString:dateString];
}

- (NSString *)dateDescriptionSinceNow
{
    NSDate *now = [NSDate date];
    int seconds = fabs([self timeIntervalSinceNow]);
    
    if (seconds < 60)
    {
        if (seconds == 1)
        {
            return [NSString stringWithFormat:@"%i second ago", seconds];
        }
        
        return [NSString stringWithFormat:@"%i seconds ago", seconds];
    }
    
    if ([self minutesBeforeDate:now] < 60)
    {
        if ([self minutesBeforeDate:now] == 1)
        {
            return [NSString stringWithFormat:@"%li minute ago", (long)[self minutesBeforeDate:now]];
        }
        
        return [NSString stringWithFormat:@"%li minutes ago", (long)[self minutesBeforeDate:now]];
    }
    
    if ([self hoursBeforeDate:now] < 6)
    {
        if ([self hoursBeforeDate:now] == 1)
        {
            return [NSString stringWithFormat:@"%li hour ago", (long)[self hoursBeforeDate:now]];
        }
        
        return [NSString stringWithFormat:@"%li hours ago", (long)[self hoursBeforeDate:now]];
    }
    
    if (self.isToday)
    {
        return [NSString stringWithFormat:@"%@ today", self.shortTimeString];
    }
    
    if (self.isYesterday)
    {
        return [NSString stringWithFormat:@"%@ yesterday", self.shortTimeString];
    }
    
    return [self formattedDateTime];
}

- (NSString *)formattedDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy h:mm a"];
    NSString *dateString = [dateFormatter stringFromDate:self];
    
    return dateString;
}

- (NSTimeInterval)timeIntervalUntilNow
{
    return [[NSDate date] timeIntervalSinceDate:self];
}

+ (instancetype)nclusiveServerDateFromString:(NSString *)string
{
    NSString *dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate *dateFromServer = [[[NSDateFormatter alloc] init] dateFromString:string format:dateFormat];
    
    return [NSDate convertToLocalFromUTCTimeZone:dateFromServer currentDateFormat:dateFormat];
}

- (NSString *)nclusiveDateStringParameter
{
    return [[[NSDateFormatter alloc] init] stringFromDate:self format:@"YYYY-MM-dd"];
}

+ (NSString *)shortStringFromMonth:(NSUInteger)month
{
    NSDateComponents *components = [[NSDate currentCalendar] components:
                                    NSCalendarUnitYear fromDate:[NSDate date]];
    components.month = month;
    
    NSDate *date = [[NSDate currentCalendar] dateFromComponents:components];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)longStringFromMonth:(NSUInteger)month {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *monthName = df.monthSymbols[month-1];
    
    return monthName;
}

+ (NSString *)shortStringFromWeekday:(NSInteger)weekday
{
    NSDate *date = [NSDate nextWeekday:weekday];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)longStringFromWeekday:(NSInteger)weekday
{
    NSDate *date = [NSDate nextWeekday:weekday];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)relativeStringFromWeekday:(NSInteger)weekday
{
    NSDate *now = [NSDate date];
    NSString *day;
    if (weekday == now.weekday)
    {
        day = @"today";
    }
    else if (weekday == now.weekday + 1)
    {
        day = @"tomorrow";
    }
    else
    {
        day = [NSDate longStringFromWeekday:weekday];
    }
    
    return day;
}


+(NSDate *)convertFromTimezone:(NSTimeZone *)timeZone1
                   toTimeZone2:(NSTimeZone *)timeZone2
                          date:(NSDate *)date
             currentDateFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    formatter1.timeZone = timeZone1;
    formatter1.dateFormat = dateFormat;
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    formatter2.timeZone = timeZone2;
    formatter2.dateFormat = dateFormat;
    
    NSString *stringToTimeZone1 = [formatter2 stringFromDate:date];
    
    NSLog(@"Input date String %@", stringToTimeZone1);
    
    return [formatter1 dateFromString:stringToTimeZone1];
}

+(NSDate *)convertFromLocalToUTCTimeZone:(NSDate *)date currentDateFormat:(NSString *)dateFormat
{
    return [self convertFromTimezone:[NSTimeZone systemTimeZone]
                         toTimeZone2:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]
                                date:date
                   currentDateFormat:dateFormat];
    
}

+(NSDate *)convertToLocalFromUTCTimeZone:(NSDate *)date currentDateFormat:(NSString *)dateFormat
{
    return [self convertFromTimezone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]
                         toTimeZone2:[NSTimeZone systemTimeZone]
                                date:date
                   currentDateFormat:dateFormat];
}


+ (NSDate *)dateWithMonth:(NSUInteger)month year:(NSUInteger)year {
    
    NSDateComponents *components = [[NSDate currentCalendar] components:
                                    NSCalendarUnitYear |
                                    NSCalendarUnitMonth fromDate:[NSDate date]];
    [components setMonth:month];
    [components setYear:year];
    return [[NSDate currentCalendar] dateFromComponents:components];
}
@end
