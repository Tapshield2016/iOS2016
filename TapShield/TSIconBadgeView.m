//
//  TSIconBadgeView.m
//  TapShield
//
//  Created by Adam Share on 5/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSIconBadgeView.h"
#import "TSBaseLabel.h"
#import <KVOController/FBKVOController.h>
#import "TSJavelinChatManager.h"

@interface TSIconBadgeView ()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) FBKVOController *kvoController;

@end

@implementation TSIconBadgeView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.layer.cornerRadius = frame.size.height/2;
        self.label = [[UILabel alloc] initWithFrame:frame];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self setNumber:0];
        [self addSubview:self.label];
        
        // create KVO controller with observer
        FBKVOController *KVOController = [FBKVOController controllerWithObserver:self];
        
        // add strong reference from observer to KVO controller
        _kvoController = KVOController;
        
        [_kvoController observe:[TSJavelinChatManager sharedManager]
                        keyPath:@"unreadMessages"
                        options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(TSIconBadgeView *badgeView, TSJavelinChatManager *chatManager, NSDictionary *change) {
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                
                                [UIView animateWithDuration:0.2 animations:^{
                                    [badgeView setNumber:chatManager.unreadMessages];
                                }];
                            }];
                        }];
    }
    return self;
}

- (void)setNumber:(NSUInteger)number {
    _number = number;
    
    _label.text = [NSString stringWithFormat:@"%lu", (unsigned long)_number];
    
    if (_number > 0) {
        self.backgroundColor = [TSColorPalette alertRed];
        _label.textColor = [TSColorPalette whiteColor];
        [self resizeView];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor clearColor];
    }
}

- (void)incrementBadgeNumber {
    
    [self setNumber:_number++];
}

- (void)clearBadge {
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setNumber:0];
    }];
}

- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    [self resizeView];
}

- (void)resizeView {
    
    [_label sizeToFit];
    CGRect labelFrame = _label.frame;
    
    if (_label.text.length > 1) {
        labelFrame.size.width += 8;
        _label.frame = labelFrame;
    }
    
    self.frame = _label.frame;
    if (self.frame.size.width < self.frame.size.height) {
        CGRect frame = self.frame;
        frame.size.width = self.frame.size.height;
        self.frame = frame;
    }
    self.layer.cornerRadius = self.frame.size.height/2;
    
    if (self.superview) {
        CGRect frame = self.frame;
        frame.origin.y = 0;
        frame.origin.x = self.superview.frame.size.width - frame.size.width + frame.size.height/4;
        self.frame = frame;
    }
    
    _label.center = CGPointMake(self.frame.size
                                .width/2, self.frame.size
                                .height/2);
    [self setNeedsDisplay];
}

@end
