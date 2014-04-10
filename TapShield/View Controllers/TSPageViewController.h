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
#import "TSHomeViewController.h"

@interface TSPageViewController : TSBasePageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

//Pages
@property (strong, nonatomic) NSArray *pageViewControllers;
@property (strong, nonatomic) TSDisarmPadViewController *disarmPadViewController;
@property (strong, nonatomic) TSEmergencyAlertViewController *emergencyAlertViewController;
@property (strong, nonatomic) TSChatViewController *chatViewController;
@property (strong, nonatomic) TSHomeViewController *homeViewController;

//UI and animation
@property (strong, nonatomic) UIView *countdownTintView;
@property (strong, nonatomic) UIView *topTintView;
@property (strong, nonatomic) UIView *bottomTintView;
@property (strong, nonatomic) UIToolbar *bottomToolbar;
@property (strong, nonatomic) UIToolbar *topToolbar;



//Alert sending
@property (nonatomic) BOOL isFirstTimeViewed;

//Transition
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIViewController *transitioningViewController;
@property (strong, nonatomic) UIViewController *currentViewController;

- (void)showChatViewController;
- (void)showAlertViewController;
- (void)showDisarmViewController;

@end
