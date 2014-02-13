//
//  TSColorPalette.m
//  TapShield
//
//  Created by Adam Share on 2/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSColorPalette.h"

@implementation TSColorPalette

+ (UIColor *)randomColor {
    int i = arc4random_uniform(6);
    UIColor *color;
    
    switch (i) {
        case 0:
            //red
            color = UIColorFromRGB(0xe6526b);
            break;
        case 1:
            //orange
            color = UIColorFromRGB(0xe78352);
            break;
        case 2:
            //yellow
            color = UIColorFromRGB(0xe6cd52);
            break;
        case 3:
            //green
            color = UIColorFromRGB(0x6ce652);
            break;
        case 4:
            //blue
            color = UIColorFromRGB(0x516ae6);
            break;
        case 5:
            //violet
            color = UIColorFromRGB(0xcc51e6);
            break;
        default:
            break;
    }
    return color;
}

+ (UIColor *)colorByAdjustingColor:(UIColor *)color Alpha:(CGFloat)newAlpha {
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([color CGColor]);
	int numComponents = (int)CGColorGetNumberOfComponents([color CGColor]);
	CGFloat newComponents[4];
    
	switch (numComponents)
	{
		case 2:
		{
			//grayscale
			newComponents[0] = oldComponents[0];
			newComponents[1] = oldComponents[0];
			newComponents[2] = oldComponents[0];
			newComponents[3] = newAlpha;
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0];
			newComponents[1] = oldComponents[1];
			newComponents[2] = oldComponents[2];
			newComponents[3] = newAlpha;
			break;
		}
	}
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *returnColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
	return returnColor;
}

+ (UIColor *)tapshieldBlue {
    return [UIColor colorWithRed:82.0f/255.0f green:183.0f/255.0f blue:232.0f/255.0f alpha:1.0f];
}

+ (UIColor *)tapshieldDarkBlue {
    return [UIColor colorWithRed:18.0f/255.0f green:122.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
}

+ (UIColor *)charcoalColor {
    return UIColorFromRGB(0x404040);
}




@end
