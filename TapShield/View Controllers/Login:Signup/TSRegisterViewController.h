//
//  TSRegisterViewController.h
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSRegisterViewController : TSBaseViewController <UITextFieldDelegate>

@property (nonatomic ,strong) NSString *emailAddress;
@property (strong, nonatomic) TSJavelinAPIUser *user;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *firstNameView;
@property (weak, nonatomic) IBOutlet UIView *lastNameView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *disarmCodeView;
@property (weak, nonatomic) IBOutlet UIView *termsView;


@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *disarmCodeTextField;

@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;

@property (weak, nonatomic) IBOutlet UIButton *addOrganizationButton;
@property (weak, nonatomic) IBOutlet UIButton *checkAgreeButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end
