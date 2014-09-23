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
@property (strong, nonatomic) UIView *insideView;

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
//    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kTalkaphoneBranding]) {
        UIImage *image = [[self imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:image forState:UIControlStateNormal];
        [self setTintColor:[TSColorPalette tapshieldBlue]];
    }
    
    _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _blurView.frame = self.bounds;
    _blurView.userInteractionEnabled = NO;
//    _blurView.layer.cornerRadius = _insideView.frame.size.height/2;
//    _blurView.layer.masksToBounds = YES;
//    CAShapeLayer *shapelayer = [[CAShapeLayer alloc] init];
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, _blurView.bounds);
    
    
    //Create a masking layer to cut out a section of the blur
//    var maskLayer = new CAShapeLayer ();
//    var maskPath = new CGPath ();
//    maskPath.AddRect (this.blurView.Bounds);
//    maskPath.AddEllipseInRect (new RectangleF (((this.blurView.Bounds.Width - CIRCLE_RECT_SIZE) / 2),   ((this.blurView.Bounds.Height - CIRCLE_RECT_SIZE) / 2), CIRCLE_RECT_SIZE, CIRCLE_RECT_SIZE));
//    maskLayer.Path = maskPath;
//    maskLayer.FillRule = CAShapeLayer.FillRuleEvenOdd;
//    this.blurView.Layer.Mask = maskLayer;
    
    [self insertSubview:_blurView atIndex:0];
}

- (void)drawRect:(CGRect)rect {
    
    [self insertSubview:_blurView atIndex:0];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
    
}

@end
