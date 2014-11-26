//
//  TSAlertAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 11/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAlertAnnotationView.h"
#import "TSAlertAnnotation.h"

static NSString * const k911AlertImage = @"Alert911";

@implementation TSAlertAnnotationView


- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.image = [UIImage imageNamed:k911AlertImage];
        self.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    
    [super setAnnotation:annotation];
    
    
}

@end
