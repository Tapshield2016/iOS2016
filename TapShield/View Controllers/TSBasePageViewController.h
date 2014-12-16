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

@property (strong, nonatomic) UIVisualEffectView *toolbar;

- (void)whiteNavigationBar;
- (void)blackNavigationBar;
- (void)transitionNavigationBarAnimatedLeft;
- (void)transitionNavigationBarAnimatedRight;

@end
