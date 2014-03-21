//
//  TSLoginTextField.m
//  TapShield
//
//  Created by Adam Share on 3/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSLoginTextField.h"

@implementation TSLoginTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customizeTextField];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self customizeTextField];
    }
    return self;
}

- (void)customizeTextField {
    
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0f;
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor lightTextColor] }];
    self.edgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

@end
