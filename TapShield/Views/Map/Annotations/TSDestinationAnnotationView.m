//
//  TSDestinationAnnotation.m
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSDestinationAnnotationView.h"
#import "TSSelectedDestinationLeftCalloutAccessoryView.h"
#import "TSSelectedDestinationAnnotation.h"

@implementation TSDestinationAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self displayTransportationType:annotation];
        self.centerOffset = CGPointMake(0, -self.image.size.height / 2);
        [self setCanShowCallout:YES];
    }
    return self;

}

- (void)displayTransportationType:(id<MKAnnotation>)annotation {
    
    self.image = [UIImage imageNamed:@"CarEndPoint"];
    
    if ([annotation isKindOfClass:[TSSelectedDestinationAnnotation class]]) {
        TSSelectedDestinationAnnotation *selectedAnnotation = (TSSelectedDestinationAnnotation *)annotation;
        
        if (selectedAnnotation.transportType == MKDirectionsTransportTypeWalking) {
            self.image = [UIImage imageNamed:@"WalkEndPoint"];
        }
    }
}

- (void)addLeftCalloutAccessoryView {
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TSSelectedDestinationLeftCalloutAccessoryView" owner:self options:nil];
    TSSelectedDestinationLeftCalloutAccessoryView *leftCalloutAccessoryView = views[0];
    self.leftCalloutAccessoryView = leftCalloutAccessoryView;
}

@end
