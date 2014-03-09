//
//  TSTextMessageBarView.m
//  TapShield
//
//  Created by Adam Share on 3/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSTextMessageBarView.h"
#import "TSColorPalette.h"

@implementation TSTextMessageBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupSubview];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview {
    
    CGRect toolBarFrame = self.frame;
    toolBarFrame.origin.y = 0.0f;
    _toolbar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    
    [self addSubview:_toolbar];
    
    [self recreateTextViewWithText:nil];
    
    CGRect sendButtonFrame = CGRectMake(self.frame.size.width/10 * 8 + 3, 0, self.frame.size.width/10 * 2, self.frame.size.height);
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = sendButtonFrame;
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[TSColorPalette tapshieldBlue] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[TSColorPalette tapshieldDarkBlue] forState:UIControlStateHighlighted];
    [self addSubview:self.sendButton];
    
    
}

- (void)recreateTextViewWithText:(NSString *)text {
    
    CGRect textViewFrame = CGRectMake(self.frame.size.width/10 + 5, self.frame.size.height/10 * 2, self.frame.size.width/10 * 7, self.frame.size.height/10 * 6);
    
    if (!_messageBoxTextView) {
        _messageBoxTextView = [[UITextView alloc] initWithFrame:textViewFrame];
        _messageBoxTextView.layer.cornerRadius = 5;
        _messageBoxTextView.tintColor = [TSColorPalette tapshieldBlue];
        _messageBoxTextView.font = [UIFont systemFontOfSize:16.0f];
        [_messageBoxTextView setTextContainerInset:UIEdgeInsetsMake(4, 5, 0, 0)];
    }
    
    if (!text) {
        text = @"";
    }
    _messageBoxTextView.text = text;
    
    [self addSubview:_messageBoxTextView];
}

- (void)addCameraButtonWithTarge:(id)target action:(SEL)action {
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:target action:action];
    cameraButton.tintColor = [UIColor lightGrayColor];
    cameraButton.imageInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [_toolbar setItems:@[cameraButton]];
}

@end
