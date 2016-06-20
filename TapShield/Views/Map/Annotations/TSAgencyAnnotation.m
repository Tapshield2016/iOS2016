//
//  TSAgencyAnnotation.m
//  TapShield
//
//  Created by Adam Share on 2/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAgencyAnnotation.h"
#import "UIImage+Resize.h"

#define kMaxWidth 100

@implementation TSAgencyAnnotation

- (void)setImage:(UIImage *)image {
    
    float ratio = 1;
    
    if (image.size.width > kMaxWidth) {
        ratio = kMaxWidth / image.size.width;
    }
    
    _image = [image resizeToSize:CGSizeMake(image.size.width * ratio, image.size.height * ratio)];
}

@end
