//
//  NSDate+Extensions.h
//  TapShield
//
//  Created by Adam Share on 5/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE 60
#define D_HOUR 3600
#define D_DAY 86400
#define D_WEEK 604800
#define D_YEAR 31556926

#define kISO8061DateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
#define kISO8601DateFormat @"yyyy-MM-dd'T'HH:mm:ssZZZZZ"
#define kISO8601DecimalDateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
#define kRFC822DateFormat @"EEE, dd MMM yyyy HH:mm:ss z"
#define kDateStampFormat @"yyyyMMdd"
#define kDateTimeFormat @"yyyyMMdd'T'HHmmss'Z'"

@interface NSDate (Utilities)
+ (NSCalendar *)currentCalendar; // avoid bottlenecks

// Relative dates from the current date
+ (NSDate *)dateTomorrow;
+ (NSDate *)dateYesterday;
+ (NSDate *)dateWithDaysFromNow:(NSInteger)days;
+ (NSDate *)dateWithDaysBeforeNow:(NSInteger)days;
+ (NSDate *)dateWithHoursFromNow:(NSInteger)dHours;
+ (NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours;
+ (NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes;
+ (NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes;

@property (nonatomic, readonly) NSDate *dateIgnoringTime;

// Short string utilities
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
- (NSString *)stringWithFormat:(NSString *)format;
@property (nonatomic, readonly) NSString *shortString;
@property (nonatomic, readonly) NSString *shortDateString;
@property (nonatomic, readonly) NSString *shortTimeString;
@property (nonatomic, readonly) NSString *shortDateTimeString;
@property (nonatomic, readonly) NSString *shortRelativeDateTimeString;
@property (nonatomic, readonly) NSString *mediumString;
@property (nonatomic, readonly) NSString *mediumDateString;
@property (nonatomic, readonly) NSString *mediumTimeString;
@property (nonatomic, readonly) NSString *mediumDateTimeString;
@property (nonatomic, readonly) NSString *mediumRelativeDateTimeString;
@property (nonatomic, readonly) NSString *longString;
@property (nonatomic, readonly) NSString *longDateString;
@property (nonatomic, readonly) NSString *longTimeString;
@property (nonatomic, readonly) NSString *longDateTimeString;
@property (nonatomic, readonly) NSString *longRelativeDateTimeString;
@property (nonatomic, readonly) NSString *iso8601String;
@property (nonatomic, readonly) NSString *monthAndYearString;

@property (readonly, nonatomic) NSString *relativeMonthWeekString;

- (NSString *)relativeDateTimeWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

+ (NSString *)fileDateTimeNowString;

// Comparing dates
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate;
- (BOOL)isEarlierThanTimeIgnoringDate:(NSDate *)aDate;
- (BOOL)isLaterThanTimeIgnoringDate:(NSDate *)aDate;

- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isYesterday;

- (BOOL)isSameWeekAsDate:(NSDate *)aDate;
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;

- (BOOL)isSameMonthAsDate:(NSDate *)aDate;
- (BOOL)isThisMonth;
- (BOOL)isNextMonth;
- (BOOL)isLastMonth;

- (BOOL)isSameYearAsDate:(NSDate *)aDate;
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;

- (BOOL)isEarlierThanDate:(NSDate *)aDate;
- (BOOL)isLaterThanDate:(NSDate *)aDate;

- (BOOL)isInFuture;
- (BOOL)isInPast;

// Date roles
- (BOOL)isTypicallyWorkday;
- (BOOL)isTypicallyWeekend;

// Adjusting dates
- (NSDate *)dateByAddingYears:(NSInteger)dYears;
- (NSDate *)dateBySubtractingYears:(NSInteger)dYears;
- (NSDate *)dateByAddingMonths:(NSInteger)dMonths;
- (NSDate *)dateBySubtractingMonths:(NSInteger)dMonths;
- (NSDate *)dateByAddingDays:(NSInteger)dDays;
- (NSDate *)dateBySubtractingDays:(NSInteger)dDays;
- (NSDate *)dateByAddingHours:(NSInteger)dHours;
- (NSDate *)dateBySubtractingHours:(NSInteger)dHours;
- (NSDate *)dateByAddingMinutes:(NSInteger)dMinutes;
- (NSDate *)dateBySubtractingMinutes:(NSInteger)dMinutes;

// Date extremes
- (NSDate *)dateAtStartOfDay;
- (NSDate *)dateAtEndOfDay;
- (NSDate *)dateAtStartOfMonth;
- (NSDate *)dateAtStartOfWeek;

// Retrieving intervals
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
- (NSInteger)minutesBeforeDate:(NSDate *)aDate;
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)hoursBeforeDate:(NSDate *)aDate;
- (NSInteger)daysAfterDate:(NSDate *)aDate;
- (NSInteger)daysBeforeDate:(NSDate *)aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;
+ (NSInteger)daysInMonth:(NSInteger)month;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;

- (NSDate *)resetDateKeepTime;
+ (NSDate *)nextWeekday:(NSInteger)day;
- (NSDate *)dateWithTime:(NSDate *)dateTime;

+ (NSDate *)dateWithISO8061Format:(NSString *)dateString;
+ (NSDate *)dateWithISO8601Format:(NSString *)dateString;
+ (NSDate *)dateFromShortDateString:(NSString *)dateString;

+ (NSDate *)dateWithMonth:(NSUInteger)month year:(NSUInteger)year;

@property (nonatomic, readonly) NSString *dateDescriptionSinceNow;
@property (nonatomic, readonly) NSString *formattedDateTime;
@property (nonatomic, readonly) NSTimeInterval timeIntervalUntilNow;

+ (instancetype)nclusiveServerDateFromString:(NSString *)string;

+ (NSString *)shortStringFromWeekday:(NSInteger)weekday;
+ (NSString *)longStringFromWeekday:(NSInteger)weekday;
+ (NSString *)relativeStringFromWeekday:(NSInteger)weekday;

@property (nonatomic, readonly) NSString *nclusiveDateStringParameter;
@property (nonatomic, readonly) NSString *fullDateString;
@property (nonatomic, readonly) NSString *monthAndYearExpirationString;
@property (nonatomic, readonly) NSString *monthAndYearShortExpirationString;

+ (NSString *)shortStringFromMonth:(NSUInteger)month;
+ (NSString *)longStringFromMonth:(NSUInteger)month;

+ (NSDate *)convertFromTimezone:(NSTimeZone *)timeZone1
                    toTimeZone2:(NSTimeZone *)timeZone2
                           date:(NSDate *)date
              currentDateFormat:(NSString *)dateFormat;

+ (NSDate *)convertFromLocalToUTCTimeZone:(NSDate *)date
                        currentDateFormat:(NSString *)dateFormat;

+ (NSDate *)convertToLocalFromUTCTimeZone:(NSDate *)date
                        currentDateFormat:(NSString *)dateFormat;

@end
