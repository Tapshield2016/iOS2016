//
//  TSForgotPasswordViewController.h
//  TapShield
//
//  Created by Adam Share on 5/1/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSLoginTextField.h"

@interface TSForgotPasswordViewController : TSNavigationViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TSLoginTextField *emailTextField;

@property (strong, nonatomic) NSString *email;

@end
