//
//  TSBasePageViewController.h
//  TapShield
//
//  Created by Adam Share on 3/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSBasePageViewController : UIPageViewController

@property (strong, nonatomic) UIImageView *navigationBarHairlineImageView;

@property (assign, nonatomic) BOOL translucentBackground;
@property (assign, nonatomic) BOOL removeNavigationShadow;

@property (strong, nonatomic) UIToolbar *toolbar;

@property (strong, nonatomic) TSLogoImageView *smallLogoImageView;
@property (strong, nonatomic) TSLogoImageView *largeLogoImageView;
@property (strong, nonatomic) TSLogoImageView *alternateLogoImageView;

@property (assign, nonatomic) BOOL showSmallLogoInNavBar;
@property (assign, nonatomic) BOOL showLargeLogo;
@property (assign, nonatomic) BOOL showAlternateLogo;


- (void)whiteNavigationBar;
- (void)blackNavigationBar;
- (void)transitionNavigationBarAnimatedLeft;
- (void)transitionNavigationBarAnimatedRight;

@end
