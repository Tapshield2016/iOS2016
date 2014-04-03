//
//  TSLoginOrSignUpViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseViewController.h"

@interface TSLoginOrSignUpViewController : TSBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

- (IBAction)showLoginView:(id)sender;
- (IBAction)showSignUpView:(id)sender;


@end
