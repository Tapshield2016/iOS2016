//
//  TSLogoImageView.m
//  TapShield
//
//  Created by Adam Share on 4/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSLogoImageView.h"
#import "TSLocationController.h"

NSString * const TSLogoImageView911 = @"911";
NSString * const TSLogoImageViewBigTapShieldLogo = @"splash_logo_small"; //@"talkaphone_logo_white";
NSString * const TSLogoImageViewBigAlternateTapShieldLogo = @"tapshield_icon"; //@"talkaphone_logo";
NSString * const TSLogoImageViewSmallTapShieldLogo = @"tapshield_icon"; //@"talkaphone_logo_gray";

@implementation TSLogoImageView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image defaultImageName:(NSString *)defaultImageName {
    
    if (!image) {
        image = [UIImage imageNamed:defaultImageName];
    }
    
    self = [super initWithImage:image];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)setImage:(UIImage *)image defaultImageName:(NSString *)defaultImageName {
    
    if (!image) {
        image = [UIImage imageNamed:defaultImageName];
    }
    
    [super setImage:image];
    
    [self setNeedsDisplay];
}

@end
