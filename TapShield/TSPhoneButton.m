//
//  TSPasscodeButton.m
//  TapShield
//
//  Created by Adam Share on 5/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSPhoneButton.h"
#import "UIImage+Color.h"
#import "UIImage+Resize.h"

@implementation TSPhoneButton

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
    
    [super initView];
    
    UIImage *image = [self imageForState:UIControlStateNormal];
    [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self setTintColor:[UIColor blackColor]];
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
    [self.backgroundFill removeFromSuperlayer];
    if (selected) {
        self.backgroundFill = [self circleLayerWithFill:[UIColor whiteColor] stroke:[UIColor whiteColor]];
        [self.layer insertSublayer:self.circleLayer atIndex:0];
    }
}

@end
