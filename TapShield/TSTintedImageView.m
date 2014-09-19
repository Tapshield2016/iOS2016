//
//  TSTintedImageView.m
//  TapShield
//
//  Created by Adam Share on 9/19/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSTintedImageView.h"
#import "TSColorPalette.h"

@implementation TSTintedImageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        UIImage *image = self.image;
        [self setImage:image];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [super setImage:image];
    
    [self setTintColor:[TSColorPalette tapshieldBlue]];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    
}

@end
