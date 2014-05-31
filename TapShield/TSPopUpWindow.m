//
//  TSPopUpWindow.m
//  TapShield
//
//  Created by Adam Share on 5/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSPopUpWindow.h"
#import "TSCircularButton.h"

#define kLabelInset 10

@interface TSPopUpWindow ()

@property (strong, nonatomic) UIView *view;
@property (assign, nonatomic) CGRect viewFrame;
@property (strong, nonatomic) TSBaseLabel *messageLabel;
@property (strong, nonatomic) UIButton *checkBoxButton;
@property (strong, nonatomic) NSString *archiveKey;

@end

@implementation TSPopUpWindow

- (id)initWithMessage:(NSString *)message {
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Initialization code
        [self windowView];
        [self addMessage:message];
    }
    return self;
}

- (instancetype)initWithActivityIndicator:(NSString *)message {
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self windowView];
        [self addMessage:message];
        [self addActivityIndicator];
    }
    return self;
}

- (instancetype)initWithRepeatCheckBox:(NSString *)archiveKey title:(NSString *)title message:(NSString *)message {
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        [self windowView];
        [self addMessage:message];
        [self addCheckBox:archiveKey];
        [self addTitle:title];
    }
    return self;
}

- (void)windowView {
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.alpha = 0.0f;
    self.windowLevel = UIWindowLevelAlert;
    
    _viewFrame = CGRectMake(0.0f, 0.0f, 260, 150);
    
    _view = [[UIView alloc] initWithFrame:_viewFrame];
    _view.center = self.center;
    _view.layer.cornerRadius = 10;
    _view.layer.masksToBounds = YES;
    _view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:_viewFrame];
    toolbar.barStyle = UIBarStyleBlack;
    [_view addSubview:toolbar];
    
    [self addSubview:_view];
    
    [self dismissButton];
}

- (void)addCheckBox:(NSString *)archiveKey {
    
    _archiveKey = archiveKey;
    
    _messageLabel.frame = CGRectMake(kLabelInset, 0, _viewFrame.size.width - kLabelInset*2, _viewFrame.size.height*.75);
    
    _checkBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_checkBoxButton addTarget:self action:@selector(checkBoxSelected) forControlEvents:UIControlEventTouchUpInside];
    [_checkBoxButton setImage:[UIImage imageNamed:@"CheckBox_Unselected"] forState:UIControlStateNormal];
    [_checkBoxButton setImage:[UIImage imageNamed:@"CheckBox_UnselectedDown"] forState:UIControlStateHighlighted];
    [_checkBoxButton setImage:[UIImage imageNamed:@"CheckBox_Selected"] forState:UIControlStateSelected];
    _checkBoxButton.frame = CGRectMake(0, _viewFrame.size.height*.75, _viewFrame.size.width, _viewFrame.size.height/4);
    
    [_checkBoxButton setTitle:@"Don't show again" forState:UIControlStateNormal];
    [_checkBoxButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_checkBoxButton setTitleColor:[TSColorPalette tapshieldBlue] forState:UIControlStateHighlighted];
    _checkBoxButton.titleLabel.font = [TSRalewayFont fontWithName:kFontRalewaySemiBold size:15.0f];
    _checkBoxButton.titleEdgeInsets = UIEdgeInsetsMake(1, 5, 0, 0);
    
    [_view addSubview:_checkBoxButton];
}

- (void)checkBoxSelected {
    
    _checkBoxButton.selected = !_checkBoxButton.selected;
    
    [[NSUserDefaults standardUserDefaults] setBool:_checkBoxButton.selected forKey:_archiveKey];
}

- (void)dismissButton {
    
    TSCircularButton *button = [[TSCircularButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setCircleColors:[UIColor whiteColor]
                  fillColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]
       highlightedFillColor:[UIColor blackColor]
          selectedFillColor:[UIColor blackColor]];
    [button drawCircleButtonHighlighted:NO selected:NO];
    [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"X" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.center = CGPointMake(_view.center.x - _viewFrame.size.width/2 + 5, _view.center.y - _viewFrame.size.height/2 + 5);
    
    [self addSubview:button];
}

- (void)cancel {
    
    [self dismiss:^(BOOL finished) {
        
    }];
}

- (void)addMessage:(NSString *)message {
    
    _messageLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(kLabelInset, 0, _viewFrame.size.width - kLabelInset*2, _viewFrame.size.height)];
    _messageLabel.numberOfLines = 0;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.text = message;
    _messageLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f];
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    [_messageLabel setAdjustsFontSizeToFitWidth:YES];
    
    [_view addSubview:_messageLabel];
}

- (void)addTitle:(NSString *)title {
    
    TSBaseLabel *label = [[TSBaseLabel alloc] initWithFrame:CGRectMake(kLabelInset, 0, _viewFrame.size.width - kLabelInset*2, _viewFrame.size.height/4)];
    label.numberOfLines = 1;
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.font = [TSRalewayFont fontWithName:kFontRalewayBold size:17.0f];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    [_view addSubview:label];
    
    _messageLabel.frame = CGRectMake(kLabelInset, _viewFrame.size.height/4, _viewFrame.size.width - kLabelInset*2, _viewFrame.size.height/2);
}

- (void)addActivityIndicator {
    
    UIActivityIndicatorView *indicatoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicatoryView startAnimating];
    indicatoryView.center = CGPointMake(_viewFrame.size.width/2, _viewFrame.size.height*.75 - 5);
    [_view addSubview:indicatoryView];
    
    _messageLabel.frame = CGRectMake(kLabelInset, 0, _viewFrame.size.width - kLabelInset*2, _viewFrame.size.height/2);
}

#pragma mark - Show/Hide Window

- (void)show {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self makeKeyAndVisible];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 1.0f;
            _view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    });
}

- (void)dismiss:(void (^)(BOOL finished))completion  {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self setHidden:YES];
            [self removeFromSuperview];
            
            if ([_popUpDelegate respondsToSelector:@selector(didDismissWindow:)]) {
                [_popUpDelegate didDismissWindow:self];
            }
            
            if (completion) {
                completion(finished);
            }
        }];
    });
}


@end
