//
//  TSAboutViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAboutViewController.h"
#import "TSAgreementViewController.h"
#import "UIViewController+Storyboard.h"

@interface TSAboutViewController ()

@end

@implementation TSAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"aboutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Send Feedback";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"EULA";
    }
    else if (indexPath.row == 2) {
        NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        cell.textLabel.text = [NSString stringWithFormat:@"v%@ (%@)", appVersionString, appBuildString];
    }
    
    cell.backgroundColor = [TSColorPalette cellBackgroundColor];
    cell.textLabel.textColor = [TSColorPalette listCellTextColor];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [self presentFeedbackEmail];
    }
    else if (indexPath.row == 1) {
        [self pushViewControllerWithClass:[TSAgreementViewController class] transitionDelegate:nil navigationDelegate:nil animated:YES];
    }
    else if (indexPath.row == 2) {
        
        [self.navigationController pushViewController:[UIViewController instantiateFromStoryboardID:@"TSThirdPartyLicenses"]
                                             animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)requestDemo:(id)sender {
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tapshield.com/demo-landing-page/"]];
}


- (void)presentFeedbackEmail {
    
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *emailTitle = [NSString stringWithFormat:@"TapShield iOS App Feedback v%@ (%@)", appVersionString, appBuildString];
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"hello@tapshield.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    [[UIView appearanceWhenContainedIn:[MFMailComposeViewController class], nil] setTintColor:[TSColorPalette tapshieldBlue]];
    mc.view.tintColor = [TSColorPalette tapshieldBlue];
    mc.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [mc.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [mc.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    mc.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
    
    [self presentViewController:mc animated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
