//
//  TSAboutViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import <MessageUI/MessageUI.h>

@interface TSAboutViewController : TSNavigationViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *versionBuildLabel;
- (IBAction)requestDemo:(id)sender;

@end
