//
//  UIImage+UImage_Color.m
//  TapShield
//
//  Created by Adam Share on 2/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageHighlightedFromColor:(UIColor *)color {
    
    //darker color
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        color = [UIColor colorWithHue:h
                           saturation:s
                           brightness:b * 0.75
                                alpha:a];
    
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)fillImageWithColor:(UIColor *)color {
    
    //image color change
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
    
    CGRect rect = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    return flippedImage;
}


- (UIImage *)reduceBrightness {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:self]; //your input image
    
    CIFilter *filter= [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:inputImage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:0.5] forKey:@"inputBrightness"];
    
    // Your output image
    CGImageRef imageRef = [context createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
    UIImage *outputImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return outputImage;
}

- (UIImage *)gaussianBlur {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:self]; //your input image
    
    CIFilter *filter= [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:5] forKey:@"inputRadius"];
    
    // Your output image
    CGImageRef imageRef = [context createCGImage:filter.outputImage fromRect:inputImage.extent];
    UIImage *outputImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return outputImage;
}

- (UIImage*)imageWithShadowOfSize:(CGFloat)shadowSize {
    
	CGFloat scale = [[UIScreen mainScreen] scale];
    
	CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef shadowContext = CGBitmapContextCreate(NULL,
													   (self.size.width + (shadowSize * 2)) * scale,
													   (self.size.height + (shadowSize * 2)) * scale,
													   CGImageGetBitsPerComponent(self.CGImage),
													   0,
													   colourSpace,
													   (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
	CGColorSpaceRelease(colourSpace);
	CGContextSetShadowWithColor(shadowContext,
								CGSizeMake( 0 * scale, 0 * scale),
								shadowSize * scale,
								[UIColor blackColor].CGColor);
    
	CGContextDrawImage(shadowContext,
					   CGRectMake(shadowSize * scale, shadowSize * scale, self.size.width * scale, self.size.height * scale),
					   self.CGImage);
    
	CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
	CGContextRelease(shadowContext);
    
	UIImage *shadowedImage = [UIImage imageWithCGImage:shadowedCGImage scale:scale orientation:UIImageOrientationUp];
	CGImageRelease(shadowedCGImage);
    
	return shadowedImage;
}

@end
