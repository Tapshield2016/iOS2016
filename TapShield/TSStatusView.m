//
//  TSStatusView.m
//  TapShield
//
//  Created by Adam Share on 7/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSStatusView.h"
#import "TSBaseLabel.h"

@interface TSStatusView ()

@property (strong, nonatomic) TSBaseLabel *label;
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
        
        _label = [[TSBaseLabel alloc] initWithFrame:self.bounds];
        _label.text = @"Searching for location";
        _label.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:12];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        self.autoresizesSubviews = YES;
        self.backgroundColor = [TSColorPalette clearColor];
        [self addSubview:_statusToolbar];
        [self addSubview:_label];
        
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
        
        _label = [[TSBaseLabel alloc] initWithFrame:self.bounds];
        _label.text = @"Searching for location";
        _label.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:12];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        self.autoresizesSubviews = YES;
        self.backgroundColor = [TSColorPalette clearColor];
        [self addSubview:_statusToolbar];
        [self addSubview:_label];
        
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
    [self.label.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    
    _label.text = string;
}

@end
