//
//  TSRegistrationNavigationController.m
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRegistrationNavigationController.h"

@interface TSRegistrationNavigationController ()

@end

@implementation TSRegistrationNavigationController


- (id)initWithoutOrganizationViewController {
    
    TSRegisterViewController *rootViewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSRegisterViewController class])];
    
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.registerViewController = rootViewController;
    }
    
    return self;
}

- (id)initWithOrganizationViewController {
    
    TSOrganizationSearchViewController *rootViewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSOrganizationSearchViewController class])];
    
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.organizationSearchViewController = rootViewController;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    self.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [self.navigationBar setTitleVerticalPositionAdjustment:-10.0f forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayMedium size:17.0f], NSFontAttributeName, nil]];
    
    _progressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_bar_s1"]];
    [_progressImageView setContentMode:UIViewContentModeCenter];
    
    _progressView = [[UIView alloc] initWithFrame:CGRectMake(self.navigationBar.frame.size.width/2 - _progressImageView.frame.size.width/2, self.navigationBar.frame.size.height/2 + 8.0f, _progressImageView.frame.size.width, _progressImageView.frame.size.width)];
    
    [_progressView addSubview:_progressImageView];
    [self.navigationBar addSubview:_progressView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
}


@end
