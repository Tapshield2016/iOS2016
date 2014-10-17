//
//  UIView+FirstResponder.h
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FirstResponder)

- (UIView *)findFirstResponder;

- (CGPoint)contentCenter;

- (UIView *)roundBezierPathCornerRadius:(float)radius;

@end
