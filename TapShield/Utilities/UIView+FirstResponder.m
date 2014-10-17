//
//  UIView+FirstResponder.m
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "UIView+FirstResponder.h"

@implementation UIView (FirstResponder)

- (UIView *)findFirstResponder {
    if ([self isFirstResponder])
        return self;
    
    for (UIView * subView in self.subviews) {
        UIView * firstResponder = [subView findFirstResponder];
        if (firstResponder != nil)
            return firstResponder;
    }
    
    return nil;
}

- (UIView *)roundBezierPathCornerRadius:(float)radius {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    return self;
}

- (CGPoint)contentCenter {
    
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

@end
