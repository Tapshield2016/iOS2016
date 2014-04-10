//
//  TSNavigationViewController.m
//  TapShield
//
//  Created by Adam Share on 3/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"

@interface TSNavigationViewController ()

@end

@implementation TSNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _navigationBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
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
