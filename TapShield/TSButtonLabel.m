//
//  TSButtonLabel.m
//  TapShield
//
//  Created by Adam Share on 3/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSButtonLabel.h"

@implementation TSButtonLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setCustomFont];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setCustomFont];
    }
    return self;
}

- (void)setCustomFont {
    
    self.font = [UIFont fontWithName:kFontRalewayLight size:16.0f];
}

@end
