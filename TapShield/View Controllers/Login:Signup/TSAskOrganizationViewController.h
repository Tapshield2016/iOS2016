//
//  TSEmailOrganizationViewController.h
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseViewController.h"
#import "TSRegistrationNavigationController.h"

@interface TSAskOrganizationViewController : TSBaseViewController
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
- (IBAction)noOrganization:(id)sender;
- (IBAction)yesOrganization:(id)sender;

@end
