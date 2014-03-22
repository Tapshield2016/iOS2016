//
//  TSRegistrationNavigationController.h
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSOrganizationSearchViewController.h"
#import "TSRegisterViewController.h"
#import "TSEmailVerificationViewController.h"
#import "TSPhoneVerificationViewController.h"

@interface TSRegistrationNavigationDelegate : NSObject <UINavigationBarDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

- (void)customizeRegistrationNavigationController:(UINavigationController *)navigationController;

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIImageView *progressImageView;
@property (nonatomic, strong) UIBarButtonItem *nextButton;

@property (nonatomic, strong) NSArray *registrationViewControllers;

@property (nonatomic, strong) TSOrganizationSearchViewController *organizationSearchViewController;
@property (nonatomic, strong) TSRegisterViewController *registerViewController;
@property (nonatomic, strong) TSEmailVerificationViewController *emailVerificationViewController;
@property (nonatomic, strong) TSPhoneVerificationViewController *phoneVerificationViewController;

@end
