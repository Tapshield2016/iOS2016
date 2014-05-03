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
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@property (strong, nonatomic) NSString *email;

- (IBAction)sendPasswordReset:(id)sender;

@end
