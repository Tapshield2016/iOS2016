//
//  TSBottomMapAlertButton.m
//  TapShield
//
//  Created by Adam Share on 4/9/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBottomMapAlertButton.h"

@implementation TSBottomMapAlertButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setCircleColors:[TSColorPalette alertRed]
                    fillColor:[TSColorPalette alertRed]
         highlightedFillColor:[TSColorPalette alertRed]
            selectedFillColor:[TSColorPalette alertRed]];
        [self drawCircleButtonHighlighted:NO selected:NO];
    }
    return self;
}

@end
