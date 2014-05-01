//
//  TSBaseButton.m
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseButton.h"

@implementation TSBaseButton

- (id)initWithFrame:(CGRect)frame fontSize:(float)fontSize
{
    self = [TSBaseButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        // Initialization code
        self.frame = frame;
        self.titleLabel.font = [TSRalewayFont customFontFromStandardFont:[UIFont systemFontOfSize:fontSize]];
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        self.titleLabel.font = [TSRalewayFont customFontFromStandardFont:self.titleLabel.font];
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
        
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.75;
    [self.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    [super setTitle:title forState:state];
}

@end
