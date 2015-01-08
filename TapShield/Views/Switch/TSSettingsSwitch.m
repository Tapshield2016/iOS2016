//
//  TSSettingsSwitch.m
//  TapShield
//
//  Created by Adam Share on 4/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSettingsSwitch.h"
#import "TSColorPalette.h"

@implementation TSSettingsSwitch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.onTintColor = [TSColorPalette tapshieldBlue];
        self.tintColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.onImage = [UIImage imageNamed:@"switch_on"];
        self.offImage = [UIImage imageNamed:@"switch_off"];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.onTintColor = [TSColorPalette tapshieldBlue];
        self.tintColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        self.onImage = [UIImage imageNamed:@"switch_on"];
        self.offImage = [UIImage imageNamed:@"switch_off"];
    }
    return self;
}

@end
