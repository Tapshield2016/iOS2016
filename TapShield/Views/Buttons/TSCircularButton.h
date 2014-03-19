//
//  TSNumberPadButton.h
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCircularButton : UIButton

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) UIColor *color;

- (void)drawCircleButton:(UIColor *)color;
- (void)addCircularAnimationWithCircleFrame:(CGRect)frame arcCenter:(CGPoint)center startAngle:(float)startAngle endAngle:(float)endAngle duration:(float)duration;

@end
