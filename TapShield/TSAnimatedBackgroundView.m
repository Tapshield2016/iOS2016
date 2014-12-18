//
//  TSAnimatedBackgroundImageView.m
//  TapShield
//
//  Created by Adam Share on 11/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAnimatedBackgroundView.h"
#import "TSColorPalette.h"
#import "UIImage+Color.h"

@interface TSAnimatedBackgroundView ()

@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIImageView *topImageView;
@property (strong, nonatomic) UIImageView *circleImageView;
@property (strong, nonatomic) UIImageView *pinShootingImageView;
@property (strong, nonatomic) UIImageView *pinRobberyImageView;

@end

@implementation TSAnimatedBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.bottomView = [[UIView alloc] initWithFrame:self.bounds];
        self.bottomView.backgroundColor = UIColorFromRGB(0x1a1a1a);
        [self addSubview:self.bottomView];
        
        UIImage *topImage = [UIImage imageNamed:@"SideMenuBG"];
        self.topImageView = [[UIImageView alloc] initWithImage:topImage];
        self.topImageView.frame = self.bounds;
        [self addSubview:self.topImageView];
        
        CGPoint point8 = CGPointMake(302/3, 172/3);
        self.circleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.circleImageView.center = point8;
        [self.circleImageView setAlpha:0.0];
        self.circleImageView.image = [[UIImage imageNamed:@"circle"] fillImageWithColor:[TSColorPalette tapshieldBlue]];
        [self addSubview:self.circleImageView];
        
        
        self.pinShootingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinOutline"]];
        self.pinShootingImageView.center = CGPointMake(70, 160);
        [self addSubview:self.pinShootingImageView];
        
        
        self.pinRobberyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinOutline2"]];
        self.pinRobberyImageView.center = CGPointMake(200, 400);
        [self addSubview:self.pinRobberyImageView];
        
        [self stopPinAnimation];
    }
    return self;
}

- (void)animateRoute {
    
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            [self animateCircle];
        }];
        [self addRouteAnimation];
    } [CATransaction commit];
    
    [self animatePin];
}

- (void)animatePin {
    [self stopPinAnimation];
    
    [UIView animateWithDuration:0.5 delay:5.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.pinShootingImageView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    [UIView animateWithDuration:0.5 delay:1.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.pinRobberyImageView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)stopPinAnimation {
    
    [self.pinShootingImageView.layer removeAllAnimations];
    CGAffineTransform t = CGAffineTransformMakeScale(0.001, 0.001);
    t = CGAffineTransformTranslate(t, 0, -self.pinShootingImageView.image.size.height);
    self.pinShootingImageView.transform = t;
    
    [self.pinRobberyImageView.layer removeAllAnimations];
    t = CGAffineTransformMakeScale(0.001, 0.001);
    t = CGAffineTransformTranslate(t, 0, -self.pinRobberyImageView.image.size.height);
    self.pinRobberyImageView.transform = t;
}

- (void)addRouteAnimation {
    
    CGPoint point1 = CGPointMake(553/3 + 3, 1704/3 + 5);
    CGPoint point2 = CGPointMake(391/3, 1524/3);
    CGPoint point3 = CGPointMake(298/3, 887/3);
    CGPoint point4 = CGPointMake(903/3, 768/3);
    CGPoint point5 = CGPointMake(774/3, 0-10);
    CGPoint point6 = CGPointMake(422/3, -10);
    CGPoint point7 = CGPointMake(444/3, 149/3);
    CGPoint point8 = CGPointMake(302/3, 172/3);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:point4];
    [path addLineToPoint:point5];
    [path addLineToPoint:point6];
    [path addLineToPoint:point7];
    [path addLineToPoint:point8];
    
    [self.pathLayer removeFromSuperlayer];
    self.pathLayer = [CAShapeLayer layer];
    self.pathLayer.frame = self.bounds;
    self.pathLayer.path = path.CGPath;
    self.pathLayer.strokeColor = [[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.5] CGColor];
    self.pathLayer.fillColor = nil;
    self.pathLayer.lineWidth = 10.0f;
    self.pathLayer.lineJoin = kCALineJoinRound;
    
    [self.bottomView.layer addSublayer:self.pathLayer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 20.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

- (void)stopRouteAnimation {
    
    [self.pathLayer removeAllAnimations];
    
    [self.pathLayer removeFromSuperlayer];
    
    [self stopCircleAnimation];
    
    [self stopPinAnimation];
}

- (void)animateCircle {
    
    self.circleImageView.transform = CGAffineTransformMakeScale(.001, .001);
    self.circleImageView.alpha = 0.5;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:2.0 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.circleImageView.transform = CGAffineTransformIdentity;
            self.circleImageView.alpha = 0.0;
        } completion:nil];
    }];
}

- (void)stopCircleAnimation{
    [self.circleImageView.layer removeAllAnimations];
    [self.circleImageView setAlpha:0.0];
}

@end
