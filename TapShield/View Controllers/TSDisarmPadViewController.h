//
//  TSDisarmPadViewController.h
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSDisarmPadViewController : TSBaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *disarmTextField;

- (IBAction)numberPressed:(id)sender;

@end
