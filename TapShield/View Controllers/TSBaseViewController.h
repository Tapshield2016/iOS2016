//
//  TSBaseViewController.h
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSConstants.h"
#import "TSAppDelegate.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSColorPalette.h"
#import "UIImage+Color.h"
#import "UIView+FirstResponder.h"
#import "TSLocationController.h"
#import "TSPushTransitionDelegate.h"
#import "TSCircularButton.h"
#import "TSFont.h"
#import "TSBaseLabel.h"
#import "TSLogoImageView.h"
#import "TSUtilities.h"
#import "UIImage+Resize.h"
#import "TSBaseTextField.h"
#import "TSPopUpWindow.h"
#import "GAITrackedViewController.h"
#import "FBShimmeringView.h"
#import "NSDate+Utilities.h"
#import "TSBasePresentationController.h"
#import "TSTransformCenterTransitioner.h"
#import "TSTopDownTransitioner.h"
#import "TSBottomUpTransitioner.h"
#import "TSTintedImageView.h"

@interface TSBaseViewController : GAITrackedViewController

- (UIViewController *)presentViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate animated:(BOOL)animated;

- (UIViewController *)pushViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)transitionDelegate navigationDelegate:(id <UINavigationControllerDelegate>)navigationDelegate animated:(BOOL)animated;

- (void)whiteNavigationBar;
- (void)blackNavigationBar;

- (void)customizeSearchBarAppearance:(UISearchBar *)searchBar;
- (void)customizeTableView:(UITableView *)tableView;

- (void)drawerCanDragForMenu:(BOOL)enabled;
- (void)drawerCanDragForContacts:(BOOL)enabled;

@property (assign, nonatomic) BOOL firstAppear;
@property (assign, nonatomic) BOOL translucentBackground;
@property (strong, nonatomic) UIVisualEffectView *toolbar;
@property (strong, nonatomic) UIImage *clearButtonImage;

@property (strong, nonatomic) TSLogoImageView *navbarLogoImageView;
@property (strong, nonatomic) UIView *logoTitleView;

@property (assign, nonatomic) BOOL showLogoInNavBar;
@property (assign, nonatomic) BOOL showAlternateLogoInNavBar;

@end
