//
//  TSMapOverlayCircle.m
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMapOverlayCircle.h"

#define MAX_RATIO 1.2
#define MIN_RATIO 0.01

#define ANIMATION_DURATION 3

//repeat forever
#define ANIMATION_REPEAT HUGE_VALF

@implementation TSMapOverlayCircle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.circle = nil;
    }
    return self;
}

- (void)startAnimatingWithColor:(UIColor *)color andFrame:(CGRect)frame{
    //create the image
    self.image = [UIImage imageNamed:@"circle.png"];
    
    UIColor *colorForAnimation = color;
    
    //image color change
    
    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context) {
        return;
    }
    
    CGContextClipToMask(context, rect, self.image.CGImage);
    CGContextSetFillColorWithColor(context, [colorForAnimation CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    self.image = flippedImage;
    
    
    //opacity animation setup
    CABasicAnimation *opacityAnimation;
    
    opacityAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = ANIMATION_DURATION;
    opacityAnimation.repeatCount = ANIMATION_REPEAT;
    //opacityAnimation.autoreverses=YES;
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.85];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    //resize animation setup
    CABasicAnimation *transformAnimation;
    
    transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    transformAnimation.duration = ANIMATION_DURATION;
    transformAnimation.repeatCount = ANIMATION_REPEAT;
    //transformAnimation.autoreverses=YES;
    transformAnimation.fromValue = [NSNumber numberWithFloat:MIN_RATIO];
    transformAnimation.toValue = [NSNumber numberWithFloat:MAX_RATIO];
    
    
    //group the two animation
    CAAnimationGroup *group = [CAAnimationGroup animation];
    
    group.repeatCount = ANIMATION_REPEAT;
    [group setAnimations:[NSArray arrayWithObjects:opacityAnimation, transformAnimation, nil]];
    group.duration = ANIMATION_DURATION;
    
    //apply the grouped animaton
    [self.layer addAnimation:group forKey:@"groupAnimation"];
}

-(void)stopAnimating{
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
}


@end
