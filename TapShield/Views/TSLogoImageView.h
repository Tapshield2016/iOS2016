//
//  TSLogoImageView.h
//  TapShield
//
//  Created by Adam Share on 4/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const TSLogoImageViewBigTapShieldLogo;
extern NSString * const TSLogoImageViewBigAlternateTapShieldLogo;
extern NSString * const TSLogoImageViewSmallTapShieldLogo;

@interface TSLogoImageView : UIImageView

@property (assign, nonatomic) float preferredHeight;

- (id)initWithImage:(UIImage *)image defaultImageName:(NSString *)defaultImageName;
- (void)setImage:(UIImage *)image defaultImageName:(NSString *)defaultImageName;

@end
