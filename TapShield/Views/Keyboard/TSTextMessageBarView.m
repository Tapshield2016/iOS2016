//
//  TSTextMessageBarView.m
//  TapShield
//
//  Created by Adam Share on 3/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSTextMessageBarView.h"
#import "TSColorPalette.h"
#import "TSUtilities.h"

static NSString * const kTextMessagePlaceholder = @"Text Message";

#define Inset_Side 3
#define Inset_Top 4
#define Font_Size 16

@implementation TSTextMessageBarView

- (instancetype)initWithFrame:(CGRect)frame
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
    
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    self.backgroundColor = [UIColor clearColor];
    
    CGRect toolBarFrame = self.bounds;
    self.toolbar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self insertSubview:self.toolbar atIndex:0];
    
    CGRect textViewFrame = CGRectMake(self.frame.size.width/10, self.frame.size.height/10 * 2, self.frame.size.width/10 * 7 + 6, self.frame.size.height/10 * 6);
    
    _textView = [[TSBaseTextView alloc] initWithFrame:textViewFrame];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_textView setTextContainerInset:UIEdgeInsetsMake(Inset_Top, Inset_Side, 0, Inset_Side)];
    _textView.font = [UIFont systemFontOfSize:Font_Size];
    _textView.placeholder = kTextMessagePlaceholder;
    
    [self addSubview:_textView];
    
    CGRect sendButtonFrame = CGRectMake(self.frame.size.width/10 * 8 + 3, 0, self.frame.size.width/10 * 2, self.frame.size.height);
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = sendButtonFrame;
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[TSColorPalette tapshieldBlue] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[TSColorPalette tapshieldDarkBlue] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[TSColorPalette lightGrayColor] forState:UIControlStateDisabled];
    [self addSubview:self.sendButton];
    
    _originalBarHeight = self.frame.size.height;
    
    [_sendButton setEnabled:NO];
}

- (void)setSendButtonTarget:(id)target action:(SEL)action {
    
    [_sendButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)addCameraButtonWithTarget:(id)target action:(SEL)action {
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:target action:action];
    cameraButton.tintColor = [UIColor lightGrayColor];
    cameraButton.imageInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [_toolbar setItems:@[cameraButton]];
}

#pragma mark - Resizing Bar

- (void)refreshBarHeightWithKeyboard:(UIView *)keyboard navigationBar:(UINavigationBar *)navigationBar {

    CGRect newBarFrame = self.frame;
    
    if (_textView.text.length == 0) {
        newBarFrame.size.height = _originalBarHeight;
        [_sendButton setEnabled:NO];
    }
    else {
        [_sendButton setEnabled:YES];
        
        CGSize textSize = [TSUtilities text:@"test" sizeWithFont:_textView.font constrainedToSize:_textView.frame.size];
        
        int height = _textView.contentSize.height - Inset_Top - 1;
        int rows = height/roundf(textSize.height);
        
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        int maxHeight = screenBounds.size.height - keyboard.frame.size.height - navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height + self.frame.size.height;
        int maxRows = maxHeight / roundf(textSize.height);
        
        
        newBarFrame.size.height = (rows * textSize.height) + (_originalBarHeight - textSize.height);
        
        if (rows > maxRows - 1) {
            newBarFrame.size.height = maxHeight;
        }
    }

    [_textView resignFirstResponder];
    self.frame = newBarFrame;
    [_textView becomeFirstResponder];
}

@end
