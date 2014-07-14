//
//  TSSpotCrimeAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSpotCrimeAnnotationView.h"
#import "TSSpotCrimeAnnotation.h"
#import "NSDate+Utilities.h"
#import "TSReportAnnotationManager.h"
#import <KVOController/FBKVOController.h>
#import "ADClusterAnnotation.h"


@implementation TSSpotCrimeAnnotationView
// Observer with KVO controller instance variable
{
    FBKVOController *_KVOController;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.centerOffset = CGPointMake(0, -self.image.size.height / 2);
        [self setCanShowCallout:YES];
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        detailButton.tintColor = [TSColorPalette tapshieldBlue];
        self.rightCalloutAccessoryView = detailButton;
    }
    return self;
    
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    
    [super setAnnotation:annotation];
    
    if ([annotation isKindOfClass:[ADClusterAnnotation class]]) {
        ((ADClusterAnnotation *)annotation).annotationView = self;
        if (((ADClusterAnnotation *)annotation).cluster) {
            annotation = [((ADClusterAnnotation *)annotation).originalAnnotations firstObject];
        }
    }
    
    if ([annotation isKindOfClass:[TSSpotCrimeAnnotation class]]) {
        TSSpotCrimeAnnotation *crimeAnnotation = (TSSpotCrimeAnnotation *)annotation;
        
        if (crimeAnnotation.socialReport) {
            self.image = [TSSpotCrimeLocation mapImageFromSocialCrimeType:[TSJavelinAPISocialCrimeReport socialReportTypesToString:crimeAnnotation.socialReport.reportType]];
        }
        else {
            self.image = [TSSpotCrimeLocation mapImageFromSpotCrimeType:crimeAnnotation.spotCrime.type];
        }
    }
}

- (void)refreshView {
    
    id<MKAnnotation> annotation = self.annotation;
    
    if ([annotation isKindOfClass:[ADClusterAnnotation class]]) {
        
        if (((ADClusterAnnotation *)annotation).cluster) {
            annotation = [((ADClusterAnnotation *)annotation).originalAnnotations firstObject];
        }
    }
    
    if ([annotation isKindOfClass:[TSSpotCrimeAnnotation class]]) {
        TSSpotCrimeAnnotation *crimeAnnotation = (TSSpotCrimeAnnotation *)annotation;
        
//        dispatch_async(dispatch_get_main_queue(), ^{
            if (crimeAnnotation.socialReport) {
                self.image = [TSSpotCrimeLocation mapImageFromSocialCrimeType:[TSJavelinAPISocialCrimeReport socialReportTypesToString:crimeAnnotation.socialReport.reportType]];
            }
            else {
                self.image = [TSSpotCrimeLocation mapImageFromSpotCrimeType:crimeAnnotation.spotCrime.type];
            }
//        });
    }
}

- (float)alphaForReportDate {
    
    float hours;
    
    id<MKAnnotation> annotation = self.annotation;
    
    if ([annotation isKindOfClass:[ADClusterAnnotation class]]) {
        if (((ADClusterAnnotation *)annotation).cluster) {
            annotation = [((ADClusterAnnotation *)annotation).originalAnnotations firstObject];
        }
        else {
            return 1.0;
        }
    }
    
    TSSpotCrimeAnnotation *spotCrimeAnnotation = (TSSpotCrimeAnnotation *)annotation;
    if (spotCrimeAnnotation.spotCrime) {
        hours = [spotCrimeAnnotation.spotCrime.date hoursBeforeDate:[NSDate date]];
    }
    else {
        hours = [spotCrimeAnnotation.socialReport.creationDate hoursBeforeDate:[NSDate date]];
    }
    
    if (hours == 0) {
        return 1.0;
    }
    
    if (hours >= MAX_HOURS) {
        return 0.2;
    }
    
    float ratio = (MAX_HOURS - hours)/MAX_HOURS;
    
    if (ratio > 0.3) {
        return ratio;
    }
    
    return 0.3;
}


@end
