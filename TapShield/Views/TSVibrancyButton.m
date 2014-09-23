//
//  TSVibrancyButton.m
//  TapShield
//
//  Created by Adam Share on 9/23/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSVibrancyButton.h"
#import "TSColorPalette.h"
#import "math.h"

@interface TSVibrancyButton ()

@property (strong, nonatomic) UIVisualEffectView *vibrancyView;
@property (strong, nonatomic) UIView *insideView;

@end

@implementation TSVibrancyButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.clipsToBounds = NO;
    _vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
    _vibrancyView.frame = self.bounds;
    _vibrancyView.userInteractionEnabled = NO;
    _insideView = [[UIView alloc] initWithFrame:_vibrancyView.bounds];
    [_vibrancyView.contentView addSubview:_insideView];
    [self insertSubview:_vibrancyView atIndex:0];
    
    [self setCircleColors:[TSColorPalette whiteColor]
                fillColor:[UIColor clearColor]
     highlightedFillColor:[TSColorPalette whiteColor]
        selectedFillColor:[TSColorPalette whiteColor]];
    [self drawCircleButton];
    
    UIImage *image = [self imageForState:UIControlStateNormal];
    [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self setTintColor:[UIColor blackColor]];
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
}

- (void)drawRect:(CGRect)rect {
    
    [self insertSubview:_vibrancyView atIndex:0];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
    
    if (!self.selected) {
        _selectedLayer.hidden = !highlighted;
    }
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
    _selectedLayer.hidden = !selected;
}

- (void)setCircleColors:(UIColor *)color fillColor:(UIColor *)fillColor highlightedFillColor:(UIColor *)highlightedFillColor selectedFillColor:(UIColor *)selectedFillColor {
    
    self.color = color;
    self.fillColor = fillColor;
    self.highlightedColor = highlightedFillColor;
    self.selectedColor = selectedFillColor;
}

- (void)drawCircleButton {
    
    self.normalLayer = [self circleLayerWithFill:self.fillColor stroke:self.color];
    self.selectedLayer = [self circleLayerWithFill:self.selectedColor stroke:self.color];
    [_insideView.layer addSublayer:self.normalLayer];
    [_insideView.layer addSublayer:self.selectedLayer];
    
    self.selectedLayer.hidden = YES;
}

- (CAShapeLayer *)circleLayerWithFill:(UIColor *)fillColor stroke:(UIColor *)strokeColor {
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    
    [circleLayer setBounds:CGRectMake(0.0, 0.0, [self bounds].size.width,
                                           [self bounds].size.height)];
    [circleLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.5, 0.5, [self bounds].size.width - 1.0, [self bounds].size.height - 1.0)];
    
    [circleLayer setPath:[path CGPath]];
    
    [circleLayer setStrokeColor:[strokeColor CGColor]];
    
    [circleLayer setLineWidth:1.0f];
    
    [circleLayer setFillColor:[fillColor CGColor]];
    
    return circleLayer;
}

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
