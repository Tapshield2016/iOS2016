//
//  TSStartAnnotationView.m
//  TapShield
//
//  Created by Adam Share on 11/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSStartAnnotationView.h"

@implementation TSStartAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        float size = 15;
        self.frame = CGRectMake(0, 0, size, size);
        UIView *blueView = [[UIView alloc] initWithFrame:self.bounds];
        blueView.backgroundColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.9];
        blueView.layer.cornerRadius = self.frame.size.height/2;
        blueView.layer.masksToBounds = YES;
        [self addSubview:blueView];
        
        [self setCanShowCallout:YES];
        
        self.accessibilityLabel = @"Starting location";
    }
    return self;
    
}

@end
