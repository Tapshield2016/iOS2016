//
//  TSRoundRectButton.m
//  TapShield
//
//  Created by Adam Share on 4/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRoundRectButton.h"

@interface TSRoundRectButton ()

@property (strong, nonatomic) UIVisualEffectView *vibrancyView;
@property (strong, nonatomic) UIView *insideView;

@end

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
}

@end
