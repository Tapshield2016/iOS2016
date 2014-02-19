//
//  TSEmailVerificationViewController.h
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSEmailVerificationViewController : TSBaseViewController

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *completeVerificationButton;
@property (weak, nonatomic) IBOutlet UIButton *resendEmailButton;

- (void)segueToPhoneVerification;

@end
