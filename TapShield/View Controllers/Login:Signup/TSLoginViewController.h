//
//  TSLoginViewController.h
//  TapShield
//
//  Created by Adam Share on 2/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseViewController.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSJavelinAPIAuthenticationResult.h"

@interface TSLoginViewController : TSBaseViewController <UITextFieldDelegate, TSJavelinAuthenticationManagerDelegate>

@property (strong, nonatomic) IBOutlet TSBaseButton *noAccountButton;
@property (strong, nonatomic) IBOutlet TSBaseButton *forgotPasswordButton;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;

@property (strong, nonatomic) TSPushTransitionDelegate *transitionDelegate;

- (IBAction)backToSignUp:(id)sender;

@end
