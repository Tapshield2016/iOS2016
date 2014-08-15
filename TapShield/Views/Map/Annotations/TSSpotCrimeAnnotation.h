//
//  TSSpotCrimeAnnotation.h
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseMapAnnotation.h"
#import "TSSpotCrimeAPIClient.h"
#import "TSJavelinAPISocialCrimeReport.h"

extern NSString * const TSSpotCrimeAnnotationPoweredBy;
extern NSString * const TSSpotCrimeAnnotationSocialReport;
static NSString *const kTYPESocialReport = @"SocialReport";
static NSString *const kTYPESpotCrime = @"SpotCrime";

@interface TSSpotCrimeAnnotation : TSBaseMapAnnotation

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) TSSpotCrimeLocation *spotCrime;
@property (strong, nonatomic) TSJavelinAPISocialCrimeReport *socialReport;

- (instancetype)initWithSpotCrime:(TSSpotCrimeLocation *)location;
- (instancetype)initWithSpocialReport:(TSJavelinAPISocialCrimeReport *)report;

@end
