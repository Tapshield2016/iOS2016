//
//  TSBottomMapButton.m
//  TapShield
//
//  Created by Adam Share on 3/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBottomMapButton.h"

@implementation TSBottomMapButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setCircleColors:[TSColorPalette tapshieldBlue]
                fillColor:[TSColorPalette tapshieldBlue]
     highlightedFillColor:[TSColorPalette tapshieldBlue]
        selectedFillColor:[TSColorPalette tapshieldBlue]];
    [self drawCircleButtonHighlighted:NO selected:NO];
}

@end
