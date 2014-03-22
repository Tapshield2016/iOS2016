//
//  TSRegistrationLabel.m
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRegistrationLabel.h"

@implementation TSRegistrationLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.textColor = [TSColorPalette activeTextColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        self.textColor = [TSColorPalette activeTextColor];
    }
    return self;
}


@end
