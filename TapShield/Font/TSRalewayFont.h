//
//  TSRalewayFont.h
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kFontRalewayRegular;
extern NSString * const kFontRalewayBold;
extern NSString * const kFontRalewayExtraBold;
extern NSString * const kFontRalewayExtraLight;
extern NSString * const kFontRalewayHeavy;
extern NSString * const kFontRalewayLight;
extern NSString * const kFontRalewayMedium;
extern NSString * const kFontRalewaySemiBold;
extern NSString * const kFontRalewayThin;


@interface TSRalewayFont : UIFont

+ (UIFont *)customFontFromStandardFont:(UIFont *)font;

@end
