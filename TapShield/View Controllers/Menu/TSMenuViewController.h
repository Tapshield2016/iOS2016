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
#import "TSRalewayFont.h"

@class MSDynamicsDrawerViewController;

@interface TSMenuViewController : UITableViewController

@property (nonatomic, weak) MSDynamicsDrawerViewController *dynamicsDrawerViewController;

- (UIViewController *)transitionToViewController:(NSString *)storyBoardIdentifier;
- (void)showMenuButton:(UIViewController *)viewController;

@end
