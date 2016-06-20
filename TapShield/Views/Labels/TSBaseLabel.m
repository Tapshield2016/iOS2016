//
//  TSBaseLabel.m
//  TapShield
//
//  Created by Adam Share on 3/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseLabel.h"

@implementation TSBaseLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.font = [TSFont customFontFromStandardFont:self.font];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
//        self.font = [TSFont customFontFromStandardFont:self.font];
    }
    return self;
}

- (void)setText:(NSString *)text {
    
    [super setText:text];
}

- (void)setText:(NSString *)text withAnimationType:(NSString *)type direction:(NSString *)direction duration:(float)duration {
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    if (type) {
        animation.type = type;
    }
    
    if (direction) {
        animation.subtype = direction;
    }
    animation.duration = duration;
    [self.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    [super setText:text];
}


@end
