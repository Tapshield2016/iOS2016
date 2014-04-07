//
//  TSRoundRectButton.m
//  TapShield
//
//  Created by Adam Share on 4/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRoundRectButton.h"

@implementation TSRoundRectButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customizButton];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customizButton];
    }
    return self;
}


- (void)customizButton {
    
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0f;
}

@end
