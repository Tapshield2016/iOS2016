//
//  TSAnimatedView.m
//  TapShield
//
//  Created by Adam Share on 3/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAnimatedView.h"

@implementation TSAnimatedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)addCircularAnimationWithCircleFrame:(CGRect)frame arcCenter:(CGPoint)center startAngle:(float)startAngle endAngle:(float)endAngle duration:(float)duration delay:(float)delay {
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = 1;
//    pathAnimation.rotationMode = kCAAnimationRotateAuto;
    pathAnimation.delegate = self;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = duration;
    pathAnimation.beginTime = CACurrentMediaTime() + delay;
    
    // Create a circle path
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    float radius = frame.size.width/2 + 20.0f + self.frame.size.width/2 + 20;
    
    CGPathAddArc(curvedPath, NULL, center.x, center.y, radius, startAngle , endAngle, NO);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    [self.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    CALayer *layer = [self.layer presentationLayer];
    self.frame = layer.frame;
}

@end
