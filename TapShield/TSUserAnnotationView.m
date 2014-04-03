//
//  TSUserAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserAnnotationView.h"

@implementation TSUserAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"user_icon"];
        [self setCanShowCallout:YES];
    }
    return self;
    
}

@end
