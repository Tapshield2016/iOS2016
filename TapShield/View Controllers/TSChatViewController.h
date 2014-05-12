//
//  TSChatViewController.h
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSTextMessageBarView.h"
#import "TSObservingInputAccessoryView.h"

@interface TSChatViewController : TSBaseViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet TSTextMessageBarView *textMessageBarBaseView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TSTextMessageBarView *textMessageBarAccessoryView;
@property (strong, nonatomic) TSObservingInputAccessoryView *inputAccessoryView;
@property (assign, nonatomic) BOOL hideBackButton;

@end
