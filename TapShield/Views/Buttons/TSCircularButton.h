//
//  TSNumberPadButton.h
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseButton.h"

@interface TSCircularButton : TSBaseButton

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) UIColor *selectedColor;

- (void)setCircleColors:(UIColor *)color fillColor:(UIColor *)fillColor highlightedFillColor:(UIColor *)highlightedFillColor selectedFillColor:(UIColor *)selectedFillColor;
- (void)drawCircleButtonHighlighted:(BOOL)highlighted selected:(BOOL)selected;

@end
