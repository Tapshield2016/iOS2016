//
//  TSVibrancyButton.h
//  TapShield
//
//  Created by Adam Share on 9/23/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSCircularButton.h"

@interface TSVibrancyButton : UIButton

@property (nonatomic, strong) CAShapeLayer *selectedLayer;
@property (nonatomic, strong) CAShapeLayer *normalLayer;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) UIColor *selectedColor;

- (void)setCircleColors:(UIColor *)color fillColor:(UIColor *)fillColor highlightedFillColor:(UIColor *)highlightedFillColor selectedFillColor:(UIColor *)selectedFillColor;
- (void)drawCircleButtonHighlighted:(BOOL)highlighted selected:(BOOL)selected;

- (CAShapeLayer *)circleLayerWithFill:(UIColor *)fillColor stroke:(UIColor *)strokeColor;

- (void)initView;

@end
