//
//  TSRalewayFont.h
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kFontWeightNormal;
extern NSString * const kFontWeightBold;
extern NSString * const kFontWeightExtraBold;
extern NSString * const kFontWeightExtraLight;
extern NSString * const kFontWeightHeavy;
extern NSString * const kFontWeightLight;
extern NSString * const kFontWeightMedium;
extern NSString * const kFontWeightSemiBold;
extern NSString * const kFontWeightThin;


@interface TSFont : UIFont

+ (UIFont *)customFontFromStandardFont:(UIFont *)font;

@end
