//
//  TSGooglePlusButton.h
//  TapShield
//
//  Created by Adam Share on 3/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <GooglePlus/GooglePlus.h>
#import "TSColorPalette.h"

@interface TSGooglePlusButton : GPPSignInButton

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) UIColor *color;

- (void)drawCircleButton:(UIColor *)color;
- (void)clearButtonStyleAndCustomize;

@end
