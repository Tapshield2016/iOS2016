//
//  TSPageViewController.h
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseViewController.h"
#import "TSDisarmPadViewController.h"
#import "TSEmergencyAlertViewController.h"
#import "TSChatViewController.h"

@interface TSPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) NSArray *alertViewControllers;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) TSDisarmPadViewController *disarmPadViewController;
@property (strong, nonatomic) TSEmergencyAlertViewController *emergencyAlertViewController;
@property (strong, nonatomic) TSChatViewController *chatViewController;
@property (strong, nonatomic) UIView *countdownTintView;


@property (nonatomic) BOOL isFirstTimeViewed;

+ (void)presentFromViewController:(UIViewController *)presentingController transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate;
- (void)showChatViewController;

@end
