//
//  TSChatViewController.h
//  TapShield
//
//  Created by Adam Share on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"
#import "TSTextMessageBarView.h"

@interface TSChatViewController : TSBaseViewController <UIScrollViewDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet TSTextMessageBarView *messageBarContainerView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;


@property (strong, nonatomic) TSObservingInputAccessoryView *inputAccessoryView;
@property (strong, nonatomic) TSTextMessageBarView *textMessageBarView;

@end
