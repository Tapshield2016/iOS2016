//
//  TSMenuViewController.h
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSColorPalette.h"
#import "TSUserProfileCell.h"
#import "TSFont.h"
#import <MessageUI/MessageUI.h>

@class MSDynamicsDrawerViewController;

@interface TSMenuViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) MSDynamicsDrawerViewController *dynamicsDrawerViewController;
@property (weak, nonatomic) IBOutlet UILabel *orgLabel;

- (UIViewController *)transitionToViewController:(NSString *)storyBoardIdentifier animated:(BOOL)animated;
- (void)showMenuButton:(UIViewController *)viewController;

- (IBAction)showAbout:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *poweredByLogo;
@property (weak, nonatomic) IBOutlet UIImageView *topLogo;

@end
