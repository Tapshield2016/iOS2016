//
//  UIImage+Resize.h
//  Juggernaut-iOS
//
//  Created by Ben Boyd on 1/7/13.
//  Copyright (c) 2013 Discovery Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)resizeToSize:(CGSize)newSize;
- (UIImage *)resizeAndCropToSize:(CGSize)targetSize;

- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)imageWithAlpha:(CGFloat) alpha;
- (UIImage *)imageWithGaussianBlur;
- (UIImage *)imageWithGaussianBlurLevel:(int)level;
- (UIImage *)imageWithCornerRadius:(float)radius;

@end
