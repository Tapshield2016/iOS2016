//
//  TSColorPalette.h
//  TapShield
//
//  Created by Adam Share on 2/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSColorPalette : UIColor

+ (UIColor *)randomColor;
+ (UIColor *)colorByAdjustingColor:(UIColor *)color Alpha:(CGFloat)newAlpha;
+ (UIColor *)tapshieldBlue;
+ (UIColor *)tapshieldDarkBlue;
+ (UIColor *)charcoalColor;
+ (UIColor *)activeTextColor;
+ (UIColor *)inActiveTextColor;
+ (UIColor *)listBackgroundColor;

@end
