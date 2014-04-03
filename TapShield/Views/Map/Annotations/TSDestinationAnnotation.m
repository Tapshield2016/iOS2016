//
//  TSDestinationAnnotation.m
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSDestinationAnnotation.h"
#import "TSSelectedDestinationLeftCalloutAccessoryView.h"

@implementation TSDestinationAnnotation

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"pins_other_icon"];
        self.centerOffset = CGPointMake(0, -self.image.size.height / 2);
        [self setCanShowCallout:YES];
    }
    return self;

}

- (void)addLeftCalloutAccessoryView {
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TSSelectedDestinationLeftCalloutAccessoryView" owner:self options:nil];
    TSSelectedDestinationLeftCalloutAccessoryView *leftCalloutAccessoryView = views[0];
    self.leftCalloutAccessoryView = leftCalloutAccessoryView;
}

@end
