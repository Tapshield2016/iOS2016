//
//  TSNoNetworkWindow.m
//  TapShield
//
//  Created by Adam Share on 7/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNoNetworkWindow.h"
#import "TSColorPalette.h"
#import "TSBaseLabel.h"

static NSString * const kDisconnected = @"No Network Data Connection";

@interface TSNoNetworkWindow ()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) UIStatusBarStyle style;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) UIWindow *upperWindow;

@end

@implementation TSNoNetworkWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)show {
    
    _upperWindow = [[UIWindow alloc] initWithFrame:self.frame];
    _upperWindow.windowLevel = UIWindowLevelStatusBar;
    _upperWindow.backgroundColor = [TSColorPalette alertRed];
    _upperWindow.alpha = 0.0;
    
    self.windowLevel = 1.5;
    self.hidden = NO;
    self.backgroundColor = [UIColor clearColor];
    CGRect frame = self.frame;
    frame.origin.y = -frame.size.height;
    _view = [[UIView alloc] initWithFrame:frame];
    _view.backgroundColor = [TSColorPalette alertRed];
    [self addSubview:_view];
    
    _label = [[TSBaseLabel alloc] initWithFrame:self.frame];
    _label.text = kDisconnected;
    _label.font = [TSFont fontWithName:kFontWeightLight size:12];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor whiteColor];
    
    [_upperWindow addSubview:_label];
    
    _style = [UIApplication sharedApplication].statusBarStyle;
    
    [self makeKeyAndVisible];
    [_upperWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:300.0
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        _view.frame = self.frame;
    } completion:^(BOOL finished) {
        [self fadeInAndOut];
    }];
}

- (void)dismiss:(void (^)(BOOL finished))completion  {
    
    [self invalidateAnimationTimer];
    [_upperWindow.layer removeAllAnimations];
    
    [[UIApplication sharedApplication] setStatusBarStyle:_style animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.frame;
            frame.origin.y = -frame.size.height;
            self.frame = frame;
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        } completion:^(BOOL finished) {
            [self setHidden:YES];
            [self removeFromSuperview];
            
            if (completion) {
                completion(finished);
            }
        }];
    });
}

- (void)invalidateAnimationTimer {
    
    [_animationTimer invalidate];
    _animationTimer = nil;
    _upperWindow.alpha = 0.0;
}

- (void)fadeInAndOut {
    
    if (!_animationTimer) {
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                           target:self
                                                         selector:@selector(fadeInAndOut)
                                                         userInfo:nil
                                                          repeats:YES];
        _animationTimer.tolerance = 1.0;
    }
    
    if (_upperWindow.alpha == 0.0) {
        [UIView animateWithDuration:0.3 animations:^{
            _upperWindow.alpha = 1.0;
        }];
    }
    else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIView animateWithDuration:0.3 animations:^{
            _upperWindow.alpha = 0.0;
        }];
    }
}



@end
