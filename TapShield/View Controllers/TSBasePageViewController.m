//
//  TSBasePageViewController.m
//  TapShield
//
//  Created by Adam Share on 3/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBasePageViewController.h"

@interface TSBasePageViewController ()

@end

@implementation TSBasePageViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _navigationBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    [self setAccessibilityTraits:UIAccessibilityTraitCausesPageTurn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    
    return YES;
}

- (void)setTranslucentBackground:(BOOL)translucentBackground {
    
    _translucentBackground = translucentBackground;
    
    if (translucentBackground) {
        
        _toolbar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _toolbar.frame = self.view.frame;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_toolbar atIndex:0];
    }
}

- (void)setRemoveNavigationShadow:(BOOL)removeNavigationShadow {
    
    _removeNavigationShadow = removeNavigationShadow;
    
    [_navigationBarHairlineImageView setHidden:removeNavigationShadow];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)whiteNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [UINavigationBar appearance].tintColor = [TSColorPalette tapshieldBlue];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.3] , NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
}

- (void)blackNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [UINavigationBar appearance].tintColor = [TSColorPalette whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette whiteColor], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette whiteColor], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.5] , NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
}

- (UIImage *)captureTopBarForAnimation {
    
    UIView *view = self.navigationController.navigationBar;
    CGRect viewRect = view.frame;
    viewRect.size.height += viewRect.origin.y;
    viewRect.origin.y = 0;
    
    view = view.superview;
    
    UIGraphicsBeginImageContext(viewRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, viewRect);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)transitionNavigationBarAnimatedLeft {
    
    [self transitionNavigationBarAnimated:YES];
}

- (void)transitionNavigationBarAnimatedRight {
    
    [self transitionNavigationBarAnimated:NO];
}

- (void)transitionNavigationBarAnimated:(BOOL)left {
    
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = -[UIApplication sharedApplication].statusBarFrame.size.height;
    frame.size.height += [UIApplication sharedApplication].statusBarFrame.size.height;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:frame];
    toolbar.barStyle = self.navigationController.navigationBar.barStyle;
    
    [self.navigationController.navigationBar insertSubview:toolbar atIndex:1];
    self.navigationController.navigationBar.clipsToBounds = NO;
    
    // Animate the view offscreen
    if (left) {
        frame.origin.x = -frame.size.width;
    }
    else {
        frame.origin.x = +frame.size.width;
    }
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations: ^{
        toolbar.frame = frame;
    } completion:^(BOOL finished) {
        [toolbar removeFromSuperview];
    }];
}


@end
