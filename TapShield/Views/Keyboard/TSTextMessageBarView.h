//
//  TSTextMessageBarView.h
//  TapShield
//
//  Created by Adam Share on 3/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSTextMessageBarView : UIView

@property (strong, nonatomic) UIView *identicalAccessoryView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *showKeyboardButton;
@property (strong, nonatomic) UIToolbar *toolbar;

@property (assign, nonatomic) BOOL identicalAccessoryViewShown;

@property (assign, nonatomic) int originalBarHeight;
@property (assign, nonatomic) int originalBarOriginY;
@property (assign, nonatomic) int originalTextViewHeight;

- (void)setupSubview;
- (void)addCameraButtonWithTarget:(id)target action:(SEL)action;
- (void)addButtonCoveringTextViewWithTarget:(id)target action:(SEL)action;
- (void)setSendButtonTarget:(id)target action:(SEL)action;

- (void)refreshBarHeightWithKeyboard:(UIView *)keyboard navigationBar:(UINavigationBar *)navigationBar;
- (void)resizeBarToReflect:(TSTextMessageBarView *)barView ;

@end
