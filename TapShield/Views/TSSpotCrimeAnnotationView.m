//
//  TSSpotCrimeAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSpotCrimeAnnotationView.h"
#import "TSSpotCrimeAnnotation.h"

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
        
        self.image = [TSSpotCrimeLocation imageFromSpotCrimeType:spotCrime.type];
    }
}


@end
