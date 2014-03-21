//
//  TSFaceBookLogin.m
//  TapShield
//
//  Created by Adam Share on 3/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSFacebookLogin.h"
#import "TSColorPalette.h"

@implementation TSFacebookLogin

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self replaceFacebookButtonAndLabel];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self replaceFacebookButtonAndLabel];
    }
    
    return self;
}


- (void)replaceFacebookButtonAndLabel {
    
    NSSet *set = ((UIButton *)[self.subviews firstObject]).allTargets;
    NSArray *actions = [((UIButton *)[self.subviews firstObject]) actionsForTarget:
                        [set.allObjects firstObject] forControlEvent:
                        UIControlEventTouchUpInside];
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.circleButton = [TSCircularButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0f, 0.0f, 62.0f, 62.0f);
    self.circleButton.frame = frame;
    [self.circleButton addTarget:[set.allObjects firstObject] action:NSSelectorFromString((NSString *)[actions firstObject]) forControlEvents:UIControlEventTouchUpInside];
    [self.circleButton drawCircleButton:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.3f]];
    
    [self addSubview:self.circleButton];
    self.clipsToBounds = NO;
    
    self.frame = frame;
}

@end
