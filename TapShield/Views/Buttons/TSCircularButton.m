//
//  TSNumberPadButton.m
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSCircularButton.h"
#import "TSColorPalette.h"
#import "math.h"

@implementation TSCircularButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setCircleColors:[[TSColorPalette whiteColor] colorWithAlphaComponent:ALPHA] fillColor:[[UIColor whiteColor] colorWithAlphaComponent:0.05] highlightedFillColor:[[UIColor blackColor] colorWithAlphaComponent:0.2] selectedFillColor:[[TSColorPalette whiteColor] colorWithAlphaComponent:ALPHA]];
        [self drawCircleButtonHighlighted:NO selected:NO];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setCircleColors:[[TSColorPalette whiteColor] colorWithAlphaComponent:ALPHA]
                    fillColor:[[UIColor whiteColor] colorWithAlphaComponent:0.05]
         highlightedFillColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]
            selectedFillColor:[[TSColorPalette whiteColor]
                               colorWithAlphaComponent:ALPHA]];
        [self drawCircleButtonHighlighted:NO selected:NO];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
    
    [self drawCircleButtonHighlighted:highlighted selected:NO];
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
    [self drawCircleButtonHighlighted:NO selected:selected];
}

- (void)setCircleColors:(UIColor *)color fillColor:(UIColor *)fillColor highlightedFillColor:(UIColor *)highlightedFillColor selectedFillColor:(UIColor *)selectedFillColor {
    
    self.color = color;
    self.fillColor = fillColor;
    self.highlightedColor = highlightedFillColor;
    self.selectedColor = selectedFillColor;
}

- (void)drawCircleButtonHighlighted:(BOOL)highlighted selected:(BOOL)selected {
    
    [self.circleLayer removeFromSuperlayer];
    
    [self setTitleColor:[TSColorPalette whiteColor] forState:UIControlStateNormal];
    
    self.circleLayer = [CAShapeLayer layer];
    
    [self.circleLayer setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width,
                                           [self bounds].size.height)];
    [self.circleLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    [self.circleLayer setPath:[path CGPath]];
    
    [self.circleLayer setStrokeColor:[self.color CGColor]];
    
    [self.circleLayer setLineWidth:1.0f];
    
    UIColor *fillColor = self.color;
    
    if (self.fillColor) {
        fillColor = self.fillColor;
    }
    
    if (highlighted) {
        fillColor = self.highlightedColor;
    }
    else if (selected) {
        fillColor = self.selectedColor;
    }
    
    [self.circleLayer setFillColor:[fillColor CGColor]];
    
    [[self layer] insertSublayer:self.circleLayer atIndex:0];
}



@end
