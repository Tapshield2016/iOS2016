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
        self.backgroundColor = [UIColor grayColor];
        
        CGRect textViewFrame = CGRectMake(self.frame.size.width / 10, self.frame.size.height/10, self.frame.size.width/10 * 7, self.frame.size.height/10 * 8);
        self.messageBoxTextView = [[UITextView alloc] initWithFrame:textViewFrame];
        [self addSubview:self.messageBoxTextView];
        
        CGRect sendButtonFrame = CGRectMake(self.frame.size.width/10 * 8, 0, self.frame.size.width/10 * 2, self.frame.size.height);
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sendButton.frame = sendButtonFrame;
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[TSColorPalette tapshieldBlue] forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[TSColorPalette tapshieldDarkBlue] forState:UIControlStateHighlighted];
        [self addSubview:self.sendButton];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor grayColor];
        
        CGRect textViewFrame = CGRectMake(self.frame.size.width / 10, self.frame.size.height/10, self.frame.size.width/10 * 7, self.frame.size.height/10 * 8);
        self.messageBoxTextView = [[UITextView alloc] initWithFrame:textViewFrame];
        [self addSubview:self.messageBoxTextView];
        
        CGRect sendButtonFrame = CGRectMake(self.frame.size.width/10 * 8, 0, self.frame.size.width/10 * 2, self.frame.size.height);
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sendButton.frame = sendButtonFrame;
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[TSColorPalette tapshieldBlue] forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[TSColorPalette tapshieldDarkBlue] forState:UIControlStateHighlighted];
        [self addSubview:self.sendButton];
    }
    return self;
}

- (void)recreateTextViewWithText:(NSString *)text {
    
    CGRect textViewFrame = CGRectMake(self.frame.size.width / 10, self.frame.size.height/10, self.frame.size.width/10 * 7, self.frame.size.height/10 * 8);
    if (!_messageBoxTextView) {
        _messageBoxTextView = [[UITextView alloc] initWithFrame:textViewFrame];
    }
    
    if (!text) {
        text = @"";
    }
    _messageBoxTextView.text = text;
    
    [self addSubview:_messageBoxTextView];
}

@end
