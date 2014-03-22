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
    
    navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [navigationController.interactivePopGestureRecognizer setEnabled:YES];
    
    _registrationViewControllers = @[[TSOrganizationSearchViewController class], [TSRegisterViewController class], [TSEmailVerificationViewController class], [TSPhoneVerificationViewController class]];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    navigationController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [navigationController.navigationBar setTitleVerticalPositionAdjustment:-10.0f forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayMedium size:17.0f], NSFontAttributeName, nil]];
    
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
            _progressImageView.image = [UIImage imageNamed:progressArray[i]];
        }
        i++;
    }
}

@end
