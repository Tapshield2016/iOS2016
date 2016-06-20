//
//  TSColorPalette.h
//  TapShield
//
//  Created by Adam Share on 2/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kTalkaphoneBranding = @"kTalkaphoneBranding";

@interface TSColorPalette : UIColor

+ (UIColor *)randomColor;
+ (UIColor *)colorByAdjustingColor:(UIColor *)color Alpha:(CGFloat)newAlpha;
+ (UIColor *)tapshieldBlue;
+ (UIColor *)tapshieldDarkBlue;
+ (UIColor *)charcoalColor;
+ (UIColor *)activeTextColor;
+ (UIColor *)inActiveTextColor;
+ (UIColor *)listBackgroundColor;
+ (UIColor *)listCellTextColor;
+ (UIColor *)listCellDetailsTextColor;
+ (UIColor *)cellSeparatorColor;
+ (UIColor *)cellBackgroundColor;
+ (UIColor *)tableViewHeaderColor;
+ (UIColor *)searchFieldBackgroundColor;
+ (UIColor *)registrationButtonTextColor;
+ (UIColor *)alertRed;
+ (UIColor *)lightChatRectGray;

+ (UIColor *)blueButtonColor;

+ (UIColor *)TSGreenColor;
+ (UIColor *)TSDarkGreenColor;

+ (UIColor *)colorFromStringHex:(NSString *)string;

@end
