//
//  TSRegistrationTextField.m
//  TapShield
//
//  Created by Adam Share on 3/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRegistrationTextField.h"

@implementation TSRegistrationTextField

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
        
        self.textColor = [TSColorPalette activeTextColor];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{ NSForegroundColorAttributeName : [TSColorPalette inActiveTextColor] }];
    }
    return self;
}

@end
