//
//  TSIntroPageViewController.h
//  TapShield
//
//  Created by Adam Share on 3/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBasePageViewController.h"
#import "TSSocialAuthorizationViewController.h"
#import "TSLoginViewController.h"
#import "TSLoginOrSignUpViewController.h"
#import "TSWelcomeViewController.h"

@interface TSIntroPageViewController : TSBasePageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) TSWelcomeViewController *welcomeViewController;
@property (strong, nonatomic) TSLoginOrSignUpViewController *logInOrSignUpViewController;
@property (strong, nonatomic) TSSocialAuthorizationViewController *socialAuthorizationViewController;
@property (strong, nonatomic) TSLoginViewController *loginViewController;

@property (strong, nonatomic) UIImageView *backgroundImage;

@property (nonatomic) BOOL isFirstTimeViewed;
@property (nonatomic, strong) NSArray *pageViewControllers;

@end
