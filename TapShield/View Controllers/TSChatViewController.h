//
//  TSChatViewController.h
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"
#import "TSTextMessageBarView.h"

@interface TSChatViewController : TSBaseViewController <UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet TSTextMessageBarView *textMessageBarBaseView;
@property (strong, nonatomic) TSTextMessageBarView *textMessageBarAccessoryView;
@property (strong, nonatomic) UIView *inputAccessoryView;
@property (strong, nonatomic) UIToolbar *toolbar;

+ (void)presentFromViewController:(UIViewController *)presentingController transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate;

@end
