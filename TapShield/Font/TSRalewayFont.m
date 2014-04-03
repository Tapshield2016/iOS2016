//
//  TSRalewayFont.m
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRalewayFont.h"

NSString * const kFontRalewayRegular = @"Raleway-Regular";
NSString * const kFontRalewayBold = @"Raleway-Bold";
NSString * const kFontRalewayExtraBold = @"Raleway-ExtraBold";
NSString * const kFontRalewayExtraLight = @"RalewayExtraLight";
NSString * const kFontRalewayHeavy = @"Raleway-Heavy";
NSString * const kFontRalewayLight = @"Raleway-Light";
NSString * const kFontRalewayMedium = @"Raleway-Medium";
NSString * const kFontRalewaySemiBold = @"Raleway-SemiBold";
NSString * const kFontRalewayThin = @"Raleway-Thin";

NSString * const kFontStyleRegular = @"font-style: normal";
NSString * const kFontStyleBold = @"font-style: bold";
NSString * const kFontStyleExtraBold = @"font-style: extra bold";
NSString * const kFontStyleExtraLight = @"font-style: extra light";
NSString * const kFontStyleHeavy = @"font-style: heavy";
NSString * const kFontStyleLight = @"font-style: light";
NSString * const kFontStyleMedium = @"font-style: medium";
NSString * const kFontStyleSemiBold = @"font-style: semi bold";
NSString * const kFontStyleThin = @"font-style: thin";

@implementation TSRalewayFont


+ (UIFont *)customFontFromStandardFont:(UIFont *)font {
    
    NSString *fontDescription = font.description;
    NSArray *components = [fontDescription componentsSeparatedByString:@"; "];
    
    NSMutableSet * matches = [NSMutableSet setWithArray:components];
    [matches filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] 'font-style'"]];
    NSString *fontStyle = matches.anyObject;
    
    fontStyle = [TSRalewayFont ralewayFontWithStyle:fontStyle];
    
    return [UIFont fontWithName:fontStyle size:font.pointSize];
}

+ (NSString *)ralewayFontWithStyle:(NSString *)style {
    
    NSString *fontName;
    
    NSArray *ralewayFontStyleArray = @[kFontRalewayBold,
                                       kFontRalewayExtraBold,
                                       kFontRalewayExtraLight,
                                       kFontRalewayHeavy,
                                       kFontRalewayLight,
                                       kFontRalewayMedium,
                                       kFontRalewayRegular,
                                       kFontRalewaySemiBold,
                                       kFontRalewayThin];
    
    NSArray *regularFontStyleArray = @[kFontStyleBold,
                                       kFontStyleExtraBold,
                                       kFontStyleExtraLight,
                                       kFontStyleHeavy,
                                       kFontStyleLight,
                                       kFontStyleMedium,
                                       kFontStyleRegular,
                                       kFontStyleSemiBold,
                                       kFontStyleThin];
    
    
    for (int i = 0; i < ralewayFontStyleArray.count; i++) {
        
        if ([regularFontStyleArray[i] isEqualToString:style]) {
            fontName = ralewayFontStyleArray[i];
            break;
        }
    }
    
    return fontName;
}


@end
