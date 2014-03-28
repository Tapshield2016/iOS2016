//
//  TSBaseViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import "TSConstants.h"
#import "TSAppDelegate.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSColorPalette.h"
#import "UIImage+Color.h"
#import "UIView+FirstResponder.h"
#import "TSLocationController.h"
#import "TSTransitionDelegate.h"
#import "TSCircularButton.h"
#import "TSRalewayFont.h"

@interface TSBaseViewController : UIViewController

- (UIViewController *)presentViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate animated:(BOOL)animated;

- (UIViewController *)pushViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)transitionDelegate navigationDelegate:(id <UINavigationControllerDelegate>)navigationDelegate animated:(BOOL)animated;

- (void)customizeSearchBarAppearance:(UISearchBar *)searchBar;
- (void)changeClearButtonStyle:(UISearchBar *)searchBar;
- (void)customizeTableView:(UITableView *)tableView;

@property (assign, nonatomic) BOOL translucentBackground;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIImage *clearButtonImage;

@end
