//
//  TSUserLocationButton.m
//  TapShield
//
//  Created by Adam Share on 2/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserLocationButton.h"

@implementation TSUserLocationButton

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
        
        [self setCircleColors:[TSColorPalette tapshieldBlue]
                    fillColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8f]
         highlightedFillColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4f]
            selectedFillColor:nil];
        
        [self drawCircleButtonHighlighted:NO selected:NO];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kTalkaphoneBranding]) {
            UIImage *image = [[self imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self setImage:image forState:UIControlStateNormal];
            [self setTintColor:[TSColorPalette tapshieldBlue]];
        }
    }
    return self;
}

@end
