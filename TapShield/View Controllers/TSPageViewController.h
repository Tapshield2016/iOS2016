//
//  TSPageViewController.h
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBasePageViewController.h"
#import "TSDisarmPadViewController.h"
#import "TSEmergencyAlertViewController.h"
#import "TSChatViewController.h"

@interface TSPageViewController : TSBasePageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) TSDisarmPadViewController *disarmPadViewController;
@property (strong, nonatomic) TSEmergencyAlertViewController *emergencyAlertViewController;
@property (strong, nonatomic) TSChatViewController *chatViewController;
@property (strong, nonatomic) UIView *countdownTintView;
@property (strong, nonatomic) NSArray *pageViewControllers;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (nonatomic) BOOL isFirstTimeViewed;

@property (strong, nonatomic) UIViewController *transitioningViewController;
@property (strong, nonatomic) UIViewController *currentViewController;

- (void)showChatViewController;
- (void)showAlertScreen;
- (void)showDisarmViewController;

@end
