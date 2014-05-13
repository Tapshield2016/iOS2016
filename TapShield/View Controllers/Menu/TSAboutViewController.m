//
//  TSAboutViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAboutViewController.h"
#import "TSAgreementViewController.h"

@interface TSAboutViewController ()

@end

@implementation TSAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    _versionBuildLabel.text =[NSString stringWithFormat:@"v%@ (%@)", appVersionString, appBuildString];
    
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
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"aboutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"EULA";
    }
    
    cell.backgroundColor = [TSColorPalette cellBackgroundColor];
    cell.textLabel.textColor = [TSColorPalette listCellTextColor];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [self pushViewControllerWithClass:[TSAgreementViewController class] transitionDelegate:nil navigationDelegate:nil animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)requestDemo:(id)sender {
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tapshield.com/demo-landing-page/"]];
}
@end
