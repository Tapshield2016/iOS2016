//
//  TSNumberPadButton.m
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSCircularButton.h"
#import "TSColorPalette.h"
#import "math.h"

@implementation TSCircularButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self drawCircleButton:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.3f] highlighted:NO];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self drawCircleButton:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.3f] highlighted:NO];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
    
    [self drawCircleButton:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.3f] highlighted:highlighted];
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
    if (selected) {
        [self drawCircleButton:[[TSColorPalette whiteColor] colorWithAlphaComponent:1.0f] selected:selected];
    }
    else {
        [self drawCircleButton:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.3f] selected:selected];
    }
}


- (void)drawCircleButton:(UIColor *)color {
    [self drawCircleButton:color highlighted:NO selected:NO];
}

- (void)drawCircleButton:(UIColor *)color highlighted:(BOOL)highlighted {
    [self drawCircleButton:color highlighted:highlighted selected:NO];
}

- (void)drawCircleButton:(UIColor *)color selected:(BOOL)selected {
    [self drawCircleButton:color highlighted:NO selected:selected];
}

- (void)drawCircleButton:(UIColor *)color highlighted:(BOOL)highlighted selected:(BOOL)selected
{
    [self.circleLayer removeFromSuperlayer];
    
    self.color = color;
    
    [self setTitleColor:[TSColorPalette whiteColor] forState:UIControlStateNormal];
    
    self.circleLayer = [CAShapeLayer layer];
    
    [self.circleLayer setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width,
                                           [self bounds].size.height)];
    [self.circleLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    [self.circleLayer setPath:[path CGPath]];
    
    [self.circleLayer setStrokeColor:[color CGColor]];
    
    [self.circleLayer setLineWidth:2.0f];
    
    UIColor *fillColor = [UIColor clearColor];
    if (highlighted) {
        fillColor = color;
    }
    else if (selected) {
        fillColor = color;
    }
    
    [self.circleLayer setFillColor:[fillColor CGColor]];
    
    [[self layer] addSublayer:self.circleLayer];
}

- (void)animate {
    
    //[self.layer animationForKey:@"position"]
}

- (void)addCircularAnimationWithCircleFrame:(CGRect)frame arcCenter:(CGPoint)center startAngle:(float)startAngle endAngle:(float)endAngle duration:(float)duration {
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = 1;
    //pathAnimation.rotationMode = @"auto";
    pathAnimation.delegate = self;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = duration;
    
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
