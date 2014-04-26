//
//  UIImage+UImage_Color.h
//  TapShield
//
//  Created by Adam Share on 2/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIImage *)imageHighlightedFromColor:(UIColor *)color;

- (UIImage *)fillImageWithColor:(UIColor *)color;
- (UIImage *)reduceBrightness;
- (UIImage *)gaussianBlur;
- (UIImage *)addBorderAndShadow;

- (UIImage *)imageWithShadowOfSize:(CGFloat)shadowSize;

@end
