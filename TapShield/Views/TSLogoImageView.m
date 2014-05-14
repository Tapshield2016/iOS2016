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
NSString * const TSLogoImageViewBigTapShieldLogo = @"splash_logo_small";
NSString * const TSLogoImageViewBigAlternateTapShieldLogo = @"tapshield_icon";
NSString * const TSLogoImageViewSmallTapShieldLogo = @"tapshield_icon";

@implementation TSLogoImageView


- (id)initWithImage:(UIImage *)image defaultImageName:(NSString *)defaultImageName {
    
    if (!image) {
        image = [UIImage imageNamed:defaultImageName];
    }
    
    self = [super initWithImage:image];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (void)setPreferredHeight:(float)preferredHeight {
    
    _preferredHeight = preferredHeight;
    
    [self checkPreferredHieght];
}

- (void)checkPreferredHieght {
    
    if (self.frame.size.height > _preferredHeight) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        
        CGRect frame = self.frame;
        frame.size.height = _preferredHeight;
        self.frame = frame;
    }
    else {
        self.contentMode = UIViewContentModeCenter;
    }
}

- (void)setImage:(UIImage *)image defaultImageName:(NSString *)defaultImageName {
    
    if (!image) {
        image = [UIImage imageNamed:defaultImageName];
    }
    
    [super setImage:image];
    
    CGPoint center = self.center;
    [self sizeToFit];
    [self checkPreferredHieght];
    self.center = center;
    
    [self setNeedsDisplay];
}

@end
