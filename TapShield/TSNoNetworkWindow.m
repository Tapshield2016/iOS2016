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

static NSString * const kDisconnected = @"No Network Connection";

@interface TSNoNetworkWindow ()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UILabel *label;

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
    
    self.windowLevel = UIWindowLevelStatusBar;
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
    
    [_view addSubview:_label];
    
    [self makeKeyAndVisible];
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:300.0
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        _view.frame = self.frame;
    } completion:nil];
}

- (void)dismiss:(void (^)(BOOL finished))completion  {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.frame;
            frame.origin.y = -frame.size.height;
            self.frame = frame;
        } completion:^(BOOL finished) {
            [self setHidden:YES];
            [self removeFromSuperview];
            
            if (completion) {
                completion(finished);
            }
        }];
    });
}


@end
