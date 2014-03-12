//
//  TSTextMessageBarView.m
//  TapShield
//
//  Created by Adam Share on 3/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSTextMessageBarView.h"
#import "TSColorPalette.h"

#define Keyboard_Height 216
#define Inset_Side 5
#define Inset_Top 4
#define Font_Size 16

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
    
    self.backgroundColor = [UIColor clearColor];
    
    CGRect toolBarFrame = self.frame;
    toolBarFrame.origin.y = 0.0f;
    self.toolbar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    [self insertSubview:self.toolbar atIndex:0];
    
    CGRect textViewFrame = CGRectMake(self.frame.size.width/10 + 5, self.frame.size.height/10 * 2, self.frame.size.width/10 * 7, self.frame.size.height/10 * 6);
    
    _textView = [[UITextView alloc] initWithFrame:textViewFrame];
    _textView.layer.cornerRadius = 5;
    _textView.tintColor = [TSColorPalette tapshieldBlue];
    _textView.font = [UIFont systemFontOfSize:Font_Size];
    [_textView setTextContainerInset:UIEdgeInsetsMake(Inset_Top, Inset_Side, 0, Inset_Side)];
    
    [self addSubview:_textView];
    
    CGRect sendButtonFrame = CGRectMake(self.frame.size.width/10 * 8 + 3, 0, self.frame.size.width/10 * 2, self.frame.size.height);
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = sendButtonFrame;
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[TSColorPalette tapshieldBlue] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[TSColorPalette tapshieldDarkBlue] forState:UIControlStateHighlighted];
    [self addSubview:self.sendButton];
    
    self.originalBarHeight = self.frame.size.height;
    self.originalBarOriginY = self.frame.origin.y;
    self.originalTextViewHeight = self.textView.frame.size.height;
    
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

- (void)addButtonCoveringTextViewWithTarget:(id)target action:(SEL)action {
    
    _showKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _showKeyboardButton.frame = _textView.frame;
    [_showKeyboardButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [_showKeyboardButton setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_showKeyboardButton];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (_identicalAccessoryViewShown) {
        //pass hit test on to the identical view attached to keyboard
        point = CGPointMake(point.x, point.y + Keyboard_Height);
        hitView = [_identicalAccessoryView hitTest:point withEvent:event];
    }
    
    return hitView;
}


#pragma mark - Resizing Bar

- (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    CGRect frame = [text boundingRectWithSize:size
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
    return frame.size;
}

- (void)refreshBarHeightWithKeyboard:(UIView *)keyboard navigationBar:(UINavigationBar *)navigationBar {
    
    CGSize textSize = [self text:@"test" sizeWithFont:_textView.font constrainedToSize:_textView.frame.size];
    
    int height = _textView.contentSize.height - Inset_Top - 1;
    int rows = height/roundf(textSize.height);
    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int maxRows = (screenBounds.size.height - keyboard.frame.size.height - navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height) / roundf(textSize.height);
    
    if (rows > maxRows - 2) {
        return;
    }
    
    CGRect newBarFrame = self.frame;
    newBarFrame.size.height = (rows * textSize.height) + (_originalBarHeight - textSize.height);
    CGRect newToolbarFrame = newBarFrame;
    newToolbarFrame.origin.y = 0;
    newBarFrame.origin.y =  _originalBarOriginY - (rows - 1) * textSize.height;
    
    CGRect newTextViewFrame = _textView.frame;
    newTextViewFrame.size.height = (rows * textSize.height) + (_originalTextViewHeight - textSize.height);
    
    
    NSLog(@"%i, %i", height, rows);
	
    [UIView animateWithDuration:0.1f
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^(void) {
                         _toolbar.frame = newToolbarFrame;
                         _textView.frame = newTextViewFrame;
                         self.frame = newBarFrame;
                     } completion:nil];
}

- (void)resizeBarToReflect:(TSTextMessageBarView *)barView {
    
    CGRect newBarFrame = self.frame;
    newBarFrame.size.height = barView.frame.size.height;
    newBarFrame.origin.y = _originalBarOriginY - (fabs(barView.frame.origin.y) - _originalBarHeight);
    
    CGRect newToolbarFrame = _toolbar.frame;
    newToolbarFrame.size.height = barView.toolbar.frame.size.height;
    
    CGRect newTextViewFrame = barView.textView.frame;
	
    [UIView animateWithDuration:0.1f
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction|
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^(void) {
                         _showKeyboardButton.frame = newTextViewFrame;
                         _toolbar.frame = newToolbarFrame;
                         _textView.frame = newTextViewFrame;
                         self.frame = newBarFrame;
                     } completion:nil];
}

@end
