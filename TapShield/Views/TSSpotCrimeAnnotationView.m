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

@implementation TSSpotCrimeAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self setImageForType:annotation];
        self.centerOffset = CGPointMake(0, -self.image.size.height / 2);
        [self setCanShowCallout:YES];
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        detailButton.tintColor = [TSColorPalette tapshieldBlue];
        self.rightCalloutAccessoryView = detailButton;
    }
    return self;
    
}


- (void)setImageForType:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[TSSpotCrimeAnnotation class]]) {
        TSSpotCrimeAnnotation *spotCrime = (TSSpotCrimeAnnotation *)annotation;
        
        if (spotCrime.socialReport) {
            self.image = [TSSpotCrimeLocation mapImageFromSocialCrimeType:spotCrime.type];
        }
        else {
            self.image = [TSSpotCrimeLocation mapImageFromSpotCrimeType:spotCrime.type];
        }
    }
}

- (float)alphaForReportDate {
    
    float hours;
    
    TSSpotCrimeAnnotation *annotation = (TSSpotCrimeAnnotation *)self.annotation;
    if (annotation.spotCrime) {
        hours = [annotation.spotCrime.date hoursBeforeDate:[NSDate date]];
    }
    else {
        hours = [annotation.socialReport.creationDate hoursBeforeDate:[NSDate date]];
    }
    
    if (hours == 0) {
        return 1.0;
    }
    
    if (hours >= 24) {
        return 0.1;
    }
    
    float ratio = (24 - hours)/24;
    
    if (ratio > 0.1) {
        return ratio;
    }
    
    return 0.1;
}


@end
