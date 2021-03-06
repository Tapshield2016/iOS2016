//
//  TSRegistrationButton.m
//  TapShield
//
//  Created by Adam Share on 3/25/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRegistrationButton.h"
#import "UIImage+Color.h"

@implementation TSRegistrationButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.titleLabel.textColor = [TSColorPalette registrationButtonTextColor];
        [self setBackgroundImage:[UIImage imageFromColor:[TSColorPalette listBackgroundColor]] forState:UIControlStateHighlighted];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setTitleColor:[TSColorPalette registrationButtonTextColor] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[TSColorPalette tapshieldBlue] CGColor] );
    CGContextSetLineWidth(context, 1.0);
    
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    
    CGContextStrokePath(context);
}


@end
