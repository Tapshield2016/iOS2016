//
//  TSRegistrationNavigationController.m
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRegistrationNavigationDelegate.h"
#import "TSNamePictureViewController.h"

NSString * const prog1 = @"progress_bar_s1";
NSString * const prog2 = @"progress_bar_s2";
NSString * const prog3 = @"progress_bar_s3";
NSString * const prog4 = @"progress_bar_s4";

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
    
    _registrationViewControllers = @[[TSOrganizationSearchViewController class], [TSRegisterViewController class], [TSEmailVerificationViewController class],  [TSNamePictureViewController class]];
    
    navigationController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [navigationController.navigationBar setTitleVerticalPositionAdjustment:-10.0f forBarMetrics:UIBarMetricsDefault];
    
    _progressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:prog1]];
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
    
    NSArray *progressArray = @[prog1, prog2, prog3, prog4];
    
    int i = 0;
    
    _progressImageView.image = [UIImage imageNamed:progressArray[2]];
    
    for (Class class in _registrationViewControllers) {
        if ([viewController isKindOfClass:class]) {
            
            _progressImageView.image = [UIImage imageNamed:progressArray[i]];
        }
        i++;
    }
}

@end
