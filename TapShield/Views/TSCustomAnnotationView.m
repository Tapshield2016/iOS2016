//
//  TSCustomAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSCustomAnnotationView.h"

NSString * const TSCustomAnnotationViewUserLocationId = @"TSCustomAnnotationViewUserLocationId";

@implementation TSCustomAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if ([reuseIdentifier isEqualToString:TSCustomAnnotationViewUserLocationId]) {
            
        }
        
    }
    return self;
}

@end
