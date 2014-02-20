//
//  TSPhoneVerificationViewController.h
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSPhoneVerificationViewController : TSBaseViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *verificationView;
@property (weak, nonatomic) IBOutlet UIImageView *iPhoneImageView;

@end
