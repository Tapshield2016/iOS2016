//
//  TSUserLocationButton.m
//  TapShield
//
//  Created by Adam Share on 2/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserLocationButton.h"

@interface TSUserLocationButton ()

@property (strong, nonatomic) UIVisualEffectView *blurView;

@end

@implementation TSUserLocationButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.layer.borderColor = [TSColorPalette tapshieldBlue].CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = self.frame.size.height/2;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kTalkaphoneBranding]) {
        UIImage *image = [[self imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:image forState:UIControlStateNormal];
        [self setTintColor:[TSColorPalette tapshieldBlue]];
    }
    
    _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _blurView.frame = self.bounds;
    _blurView.userInteractionEnabled = NO;
    [self roundBezierPathCornersOnView:_blurView radius:self.bounds.size.height/2];
    [self insertSubview:_blurView atIndex:0];
}

- (void)drawRect:(CGRect)rect {
    
    [self insertSubview:_blurView atIndex:0];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
    
}

- (UIView *)roundBezierPathCornersOnView:(UIView *)view radius:(float)radius {
        
        UIView *roundedView = view;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = roundedView.bounds;
        maskLayer.path = maskPath.CGPath;
        roundedView.layer.mask = maskLayer;
        return roundedView;
}

@end
