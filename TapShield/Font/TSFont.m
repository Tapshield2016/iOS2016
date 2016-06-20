//
//  TSRalewayFont.m
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSFont.h"

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

NSString * const kFontWeightNormal = @"HelveticaNeue";
NSString * const kFontWeightBold = @"HelveticaNeue-Bold";
NSString * const kFontWeightExtraBold = @"HelveticaNeue-Bold";
NSString * const kFontWeightExtraLight = @"HelveticaNeue-UltraLight";
NSString * const kFontWeightHeavy = @"HelveticaNeue-Bold";
NSString * const kFontWeightLight = @"HelveticaNeue-Light";
NSString * const kFontWeightMedium = @"HelveticaNeue-Medium";
NSString * const kFontWeightSemiBold = @"HelveticaNeue-Bold";
NSString * const kFontWeightThin = @"HelveticaNeue-Thin";

NSString * const kFontStyleRegular = @"font-style: normal";
NSString * const kFontStyleBold = @"font-style: bold";
NSString * const kFontStyleExtraBold = @"font-style: extra bold";
NSString * const kFontStyleExtraLight = @"font-style: extra light";
NSString * const kFontStyleHeavy = @"font-style: heavy";
NSString * const kFontStyleLight = @"font-style: light";
NSString * const kFontStyleMedium = @"font-style: medium";
NSString * const kFontStyleSemiBold = @"font-style: semi bold";
NSString * const kFontStyleThin = @"font-style: thin";

@implementation TSFont


+ (UIFont *)customFontFromStandardFont:(UIFont *)font {
    
    NSString *fontDescription = font.description;
    NSArray *components = [fontDescription componentsSeparatedByString:@"; "];
    
    NSMutableSet *matches = [NSMutableSet setWithArray:components];
    [matches filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] 'font-style'"]];
    NSString *fontStyle = matches.anyObject;
    
    fontStyle = [TSFont applicationFontWithStyle:fontStyle];
    
    return [UIFont fontWithName:fontStyle size:font.pointSize];
}

+ (NSString *)applicationFontWithStyle:(NSString *)style {
    
    NSString *fontName;
    
    NSArray *ralewayFontStyleArray = @[kFontWeightBold,
                                       kFontWeightExtraBold,
                                       kFontWeightExtraLight,
                                       kFontWeightHeavy,
                                       kFontWeightLight,
                                       kFontWeightMedium,
                                       kFontWeightNormal,
                                       kFontWeightSemiBold,
                                       kFontWeightThin];
    
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
