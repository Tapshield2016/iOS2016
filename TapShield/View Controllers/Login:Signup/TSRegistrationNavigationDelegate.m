//
//  TSRegistrationNavigationController.m
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRegistrationNavigationDelegate.h"

NSString * const progress1 = @"progress_bar_s1";
NSString * const progress2 = @"progress_bar_s2";
NSString * const progress3 = @"progress_bar_s3";
NSString * const progress4 = @"progress_bar_s4";

@interface TSRegistrationNavigationDelegate ()

@end

@implementation TSRegistrationNavigationDelegate


- (id)init {
    
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}


- (void)customizeRegistrationNavigationController:(UINavigationController *)navigationController {
    // Do any additional setup after loading the view.
    
    navigationController.delegate = self;
    
    _registrationViewControllers = @[[TSOrganizationSearchViewController class], [TSRegisterViewController class], [TSEmailVerificationViewController class], [TSPhoneVerificationViewController class]];
    
    navigationController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [navigationController.navigationBar setTitleVerticalPositionAdjustment:-10.0f forBarMetrics:UIBarMetricsDefault];
    
    _progressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:progress1]];
    [_progressImageView setContentMode:UIViewContentModeCenter];
    
    _progressView = [[UIView alloc] initWithFrame:CGRectMake(navigationController.navigationBar.frame.size.width/2 - _progressImageView.frame.size.width/2, navigationController.navigationBar.frame.size.height/2 + 8.0f, _progressImageView.frame.size.width, _progressImageView.frame.size.width)];
    
    [_progressView addSubview:_progressImageView];
    [navigationController.navigationBar addSubview:_progressView];
}

#pragma mark - Navigation Bar Delegate

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
    
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
    
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    return YES;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    
    return YES;
}


#pragma mark - Navigation Controller Delegate



- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSArray *progressArray = @[progress1, progress2, progress3, progress4];
    
    int i = 0;
    for (Class class in _registrationViewControllers) {
        if ([viewController isKindOfClass:class]) {
            
//            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, _progressView.frame.size.height)];
//            containerView.opaque = NO;
//            containerView.backgroundColor = [UIColor clearColor];
//            containerView.clipsToBounds = YES;
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:progressArray[i]]];
//            imageView.contentMode = UIViewContentModeCenter;
//            
//            [containerView addSubview:imageView];
//            [_progressView addSubview:containerView];
//            
//            [UIView animateWithDuration:1.0f animations:^{
//                containerView.frame = _progressImageView.frame;
//            } completion:^(BOOL finished) {
//                _progressImageView.image = imageView.image;
//                [containerView removeFromSuperview];
//            }];
            
            _progressImageView.image = [UIImage imageNamed:progressArray[i]];
        }
        i++;
    }
}

@end
