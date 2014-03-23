//
//  TSWelcomeViewController.m
//  TapShield
//
//  Created by Adam Share on 3/19/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSWelcomeViewController.h"
#import "TSIntroPageViewController.h"
#import "TSGradientSwipeViewController.h"

@interface TSWelcomeViewController ()

@end

@implementation TSWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_smallLogoImageView setHidden:YES];
    
    self.view.backgroundColor = [UIColor clearColor];
    _swipeLabelView.alpha = 0.0f;
    _welcomeLabel.alpha = 0.0f;
    
    _isFirstTimeViewed = YES;
    
    _swipeViewController = [[TSGradientSwipeViewController alloc] init];
    _swipeViewController.view.frame = _swipeLabelView.bounds;
    _swipeViewController.label.frame = _swipeLabelView.bounds;
    _swipeViewController.imageView.frame = _swipeLabelView.bounds;
    [_swipeLabelView addSubview:_swipeViewController.view];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_isFirstTimeViewed) {
        [self performSelector:@selector(animation) withObject:nil afterDelay:1.0f];
    }
    _isFirstTimeViewed = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_swipeViewController.view removeFromSuperview];
}

- (void)animation {
    
    CGRect frame = _smallLogoImageView.frame;
    
    [UIView animateWithDuration:1.5f delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        _splashLargeLogoImageView.frame = frame;
    } completion:^(BOOL finished) {
        
        TSIntroPageViewController *pageView = (TSIntroPageViewController *)self.parentViewController;
        [pageView.logoImage setHidden:NO];
        pageView.logoImage.frame = _smallLogoImageView.frame;
        
        [_splashLargeLogoImageView setHidden:YES];
    }];
    
    [UIView animateWithDuration:0.5 delay:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        _swipeLabelView.alpha = 1.0f;
        _welcomeLabel.alpha = 1.0f;
    } completion:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)animate:(id)sender {
    [self animation];
}
@end
