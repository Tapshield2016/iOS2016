//
//  TSTextMessageBarView.h
//  TapShield
//
//  Created by Adam Share on 3/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSTextMessageBarView : UIView

@property (strong, nonatomic) UITextView *messageBoxTextView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIToolbar *toolbar;

- (void)recreateTextViewWithText:(NSString *)text;
- (void)addCameraButtonWithTarget:(id)target action:(SEL)action;

@end
