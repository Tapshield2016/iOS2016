//
//  TSJavelinAPISocialCrimeReport.h
//  TapShield
//
//  Created by Adam Share on 5/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"
#import <CoreLocation/CoreLocation.h>


#define kSocialCrimeReportShortArray @"AB", @"AS", @"CA", @"DI", @"DR", @"H", @"MH", @"O", @"S", @"SA", @"T", @"V", nil
#define kSocialCrimeReportLongArray @"Abuse", @"Assault", @"Car Accident", @"Disturbance", @"Drugs/Alcohol", @"Harassment", @"Mental Health", @"Other", @"Suggestion", @"Suspicious Activity", @"Theft", @"Vandalism", nil

typedef enum {
    Abuse,
    Assault,
    CarAccident,
    Disturbance,
    DrugsAlcohol,
    Harassment,
    MentalHealth,
    Other,
    Suggestion,
    SuspiciousActivity,
    Theft,
    Vandalism,
} SocialReportTypes;

//@"RN",
//@"Repair Needed",


@interface TSJavelinAPISocialCrimeReport : TSJavelinAPIBaseModel

//body = Assault;
//"creation_date" = "2014-05-11T09:08:36.690Z";
//distance = "0.01534496941983814";
//"last_modified" = "2014-05-11T09:08:36.690Z";
//"report_image_url" = "<null>";
//"report_latitude" = "26.115649518878";
//"report_longitude" = "-80.1394969373621";
//"report_point" = "POINT (-80.1394969373620967 26.1156495188780085)";
//"report_type" = AS;
//reporter = "https://dev.tapshield.com/api/v1/users/112/";
//url = "https://dev.tapshield.com/api/v1/social-crime-reports/32/";

@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *lastModified;
@property (strong, nonatomic) NSString *reportImageUrl;
@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) CLLocationDistance distance;
@property (strong, nonatomic) CLLocation *location;
@property (assign, nonatomic) SocialReportTypes reportType;
@property (strong, nonatomic) NSString *user;

+ (NSArray *)socialCrimeReportArray:(NSArray *)socialCrimes;

+ (NSString*)socialReportTypesToString:(SocialReportTypes)enumValue;
+ (NSString*)socialReportTypesToShortString:(SocialReportTypes)enumValue;

@end
