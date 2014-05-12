//
//  TSSpotCrimeAnnotation.m
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSpotCrimeAnnotation.h"
#import "TSUtilities.h"

@implementation TSSpotCrimeAnnotation

- (instancetype)initWithSpotCrime:(TSSpotCrimeLocation *)location
{
    self = [super initWithCoordinates:location.coordinate placeName:[NSString stringWithFormat:@"%@ %@", location.type, location.date] description:location.address];
    if (self) {
        
        _spotCrime = location;
        _type = location.type;
    }
    return self;
}

- (instancetype)initWithSpocialReport:(TSJavelinAPISocialCrimeReport *)report
{
    self = [super initWithCoordinates:report.location.coordinate placeName:[NSString stringWithFormat:@"%@ %@", [TSJavelinAPISocialCrimeReport socialReportTypesToString:report.reportType], [TSUtilities formattedDateTime:report.creationDate]] description:report.address];
    if (self) {
        
        _socialReport = report;
        _type = [TSJavelinAPISocialCrimeReport socialReportTypesToString:report.reportType];
    }
    return self;
}

@end
