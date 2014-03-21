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

- (void)drawCircleButton:(UIColor *)color;

@end
