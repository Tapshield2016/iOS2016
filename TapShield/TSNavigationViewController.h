//
//  TSNavigationViewController.h
//  TapShield
//
//  Created by Adam Share on 3/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSNavigationViewController : TSBaseViewController

@property (strong, nonatomic) UIImageView *navigationBarHairlineImageView;
@property (assign, nonatomic) BOOL translucentBackground;
@property (assign, nonatomic) BOOL removeNavigationShadow;

- (void)whiteNavigationBar;
- (void)blackNavigationBar;
- (void)transitionNavigationBarAnimatedLeft;
- (void)transitionNavigationBarAnimatedRight;

@end
