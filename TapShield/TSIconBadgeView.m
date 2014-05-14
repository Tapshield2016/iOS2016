//
//  TSIconBadgeView.m
//  TapShield
//
//  Created by Adam Share on 5/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSIconBadgeView.h"
#import "TSBaseLabel.h"

@interface TSIconBadgeView ()

@property (strong, nonatomic) UILabel *label;

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
    }
    return self;
}

- (void)setNumber:(NSUInteger)number {
    _number = number;
    
    _label.text = [NSString stringWithFormat:@"%i", _number];
    
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
        frame.origin.y = -frame.size.height/2;
        frame.origin.x = self.superview.frame.size.width - frame.size.height/2 - 8;
        self.frame = frame;
    }
    
    _label.center = CGPointMake(self.frame.size
                                .width/2, self.frame.size
                                .height/2);
    [self setNeedsDisplay];
}

@end
