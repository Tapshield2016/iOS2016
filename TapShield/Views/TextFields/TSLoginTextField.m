//
//  TSLoginTextField.m
//  TapShield
//
//  Created by Adam Share on 3/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSLoginTextField.h"

@interface TSLoginTextField ()

@property (strong, nonatomic) UIVisualEffectView *vibrancyView;
@property (strong, nonatomic) UIView *insideView;

@end

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
    
    _vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
    _vibrancyView.frame = self.bounds;
    _vibrancyView.userInteractionEnabled = NO;
    _insideView = [[UIView alloc] initWithFrame:_vibrancyView.bounds];
    [_vibrancyView.contentView addSubview:_insideView];
    [self insertSubview:_vibrancyView atIndex:0];
    
    _insideView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _insideView.layer.cornerRadius = 5.0f;
    _insideView.layer.masksToBounds = YES;
    _insideView.layer.borderWidth = 1.0f;
    
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{ NSForegroundColorAttributeName : [TSColorPalette lightTextColor] }];
    self.edgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
}



@end
