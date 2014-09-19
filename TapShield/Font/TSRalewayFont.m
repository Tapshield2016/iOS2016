//
//  TSRalewayFont.m
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRalewayFont.h"

//Helvetica Neue
//
//HelveticaNeue
//HelveticaNeue-Bold
//HelveticaNeue-BoldItalic
//HelveticaNeue-CondensedBlack
//HelveticaNeue-CondensedBold
//HelveticaNeue-Italic
//HelveticaNeue-Light
//HelveticaNeue-LightItalic
//HelveticaNeue-Medium
//HelveticaNeue-MediumItalic
//HelveticaNeue-Thin
//HelveticaNeue-Thin_Italic
//HelveticaNeue-UltraLight
//HelveticaNeue-UltraLightItalic

NSString * const kFontRalewayRegular = @"HelveticaNeue";
NSString * const kFontRalewayBold = @"HelveticaNeue-Bold";
NSString * const kFontRalewayExtraBold = @"HelveticaNeue-Bold";
NSString * const kFontRalewayExtraLight = @"HelveticaNeue-UltraLight";
NSString * const kFontRalewayHeavy = @"HelveticaNeue-Bold";
NSString * const kFontRalewayLight = @"HelveticaNeue-Light";
NSString * const kFontRalewayMedium = @"HelveticaNeue-Medium";
NSString * const kFontRalewaySemiBold = @"HelveticaNeue-Bold";
NSString * const kFontRalewayThin = @"HelveticaNeue-Thin";

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
