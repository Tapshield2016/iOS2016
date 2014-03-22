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

@interface TSRegistrationNavigationController : UINavigationController <UINavigationBarDelegate, UINavigationControllerDelegate>


- (id)initWithoutOrganizationViewController;
- (id)initWithOrganizationViewController;

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIImageView *progressImageView;
@property (nonatomic, strong) TSOrganizationSearchViewController *organizationSearchViewController;
@property (nonatomic, strong) TSRegisterViewController *registerViewController;

@end
