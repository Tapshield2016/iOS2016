//
//  TSSpotCrimeAnnotation.m
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSpotCrimeAnnotation.h"
#import "TSUtilities.h"

NSString * const TSSpotCrimeAnnotationPoweredBy = @"";
NSString * const TSSpotCrimeAnnotationSocialReport = @"User submitted tip";

@implementation TSSpotCrimeAnnotation

- (instancetype)initWithSpotCrime:(TSSpotCrimeLocation *)location
{
    self = [super initWithCoordinates:location.coordinate placeName:location.type description:[location.date dateDescriptionSinceNow]];
    if (self) {
        self.title = location.type;
        _spotCrime = location;
        _type = location.type;
        self.groupTag = kTYPESpotCrime;
        
        self.title = _type;
    }
    return self;
}

- (instancetype)initWithSpocialReport:(TSJavelinAPISocialCrimeReport *)report
{
    self = [super initWithCoordinates:report.location.coordinate placeName:[TSJavelinAPISocialCrimeReport socialReportTypesToString:report.reportType] description:[report.creationDate dateDescriptionSinceNow]];
    if (self) {
        _socialReport = report;
        _type = [TSJavelinAPISocialCrimeReport socialReportTypesToString:report.reportType];
        self.groupTag = kTYPESocialReport;
        
        self.title = _type;
    }
    return self;
}

@end
