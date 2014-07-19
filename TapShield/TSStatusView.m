//
//  TSStatusView.m
//  TapShield
//
//  Created by Adam Share on 7/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSStatusView.h"
#import "TSBaseLabel.h"

NSString * const kTSStatusViewApproxAddress = @"Approximate Location";
NSString * const kTSStatusViewTimeRemaining = @"Time Remaining";

@interface TSStatusView ()

@property (strong, nonatomic) TSBaseLabel *label;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIToolbar *statusToolbar;

@end

@implementation TSStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _statusToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        [_statusToolbar.layer setAffineTransform:CGAffineTransformMakeScale(1, -1)];
        _statusToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _statusToolbar.barTintColor = [TSColorPalette alertRed];
        
        CGRect frame = self.bounds;
        frame.origin.y = frame.size.height*.35;
        frame.size.height *= .65;
        _label = [[TSBaseLabel alloc] initWithFrame:frame];
        _label.text = @"Searching for location";
        _label.font = [UIFont systemFontOfSize:18];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        frame = self.bounds;
        frame.size.height *= .4;
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
        _titleLabel.text = kTSStatusViewApproxAddress;
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        self.autoresizesSubviews = YES;
        self.backgroundColor = [TSColorPalette clearColor];
        [self addSubview:_statusToolbar];
        [self addSubview:_label];
        [self addSubview:_titleLabel];
        
        _originalHeight = self.frame.size.height;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _statusToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        [_statusToolbar.layer setAffineTransform:CGAffineTransformMakeScale(1, -1)];
        _statusToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _statusToolbar.barTintColor = [TSColorPalette tapshieldBlue];
        
        CGRect frame = self.bounds;
        frame.origin.y = frame.size.height*.35 + 1;
        frame.size.height *= .65;
        _label = [[TSBaseLabel alloc] initWithFrame:frame];
        _label.text = @"Searching for location";
        _label.font = [UIFont systemFontOfSize:18];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        frame = self.bounds;
        frame.size.height *= .4;
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
        _titleLabel.text = kTSStatusViewApproxAddress;
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        self.autoresizesSubviews = YES;
        self.backgroundColor = [TSColorPalette clearColor];
        [self addSubview:_statusToolbar];
        [self addSubview:_label];
        [self addSubview:_titleLabel];
        
        _originalHeight = self.frame.size.height;
    }
    return self;
}

- (void)setText:(NSString *)string {
    
    float duration = 0.2;
    if (!string) {
        duration = 0.1;
    }
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = duration;
    [_label.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    
    _label.text = string;
}

- (void)setTitle:(NSString *)title message:(NSString *)message {
    
    float duration = 0.2;
    if (!title) {
        duration = 0.1;
    }
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = duration;
    [_label.layer addAnimation:animation forKey:@"kCATransitionFade"];
    [_titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    
    _label.text = message;
    _titleLabel.text = title;
}

- (void)alternateMessages {
    
    int timeRemaining = [_timeLeft intValue];
    
    if ([_titleLabel.text isEqualToString:kTSStatusViewTimeRemaining] || timeRemaining < 10) {
        _label.text = _userLocation;
        _titleLabel.text = kTSStatusViewApproxAddress;
    }
    else {
        _label.text = _timeLeft;
        _titleLabel.text = kTSStatusViewTimeRemaining;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(alternateMessages) withObject:nil afterDelay:5.0];
}



@end
