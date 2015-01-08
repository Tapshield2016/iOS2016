//
//  TSPasscodeTableViewController.h
//  TapShield
//
//  Created by Adam Share on 5/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewController.h"

@interface TSPasscodeTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet TSBaseTextField *currentPasscodeTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *passcodeTextField;
@property (weak, nonatomic) IBOutlet TSBaseTextField *repeatPasscodeTextField;
- (IBAction)forgotPassword:(id)sender;

@end
