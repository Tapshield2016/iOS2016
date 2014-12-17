//
//  TSBottomMapButton.m
//  TapShield
//
//  Created by Adam Share on 3/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBottomMapButton.h"
#import "UIImage+Color.h"

@interface TSBottomMapButton ()

@end

@implementation TSBottomMapButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setup];
        
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 15, 0);
        _originalImageInsets = self.imageEdgeInsets;
        _originalTitleInsets = self.titleEdgeInsets;
        _labelYOffset = 31;
        [self setBackgroundImage:[UIImage imageFromColor:[TSColorPalette grayColor]] forState:UIControlStateSelected];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setup];
        _originalImageInsets = self.imageEdgeInsets;
        _originalTitleInsets = self.titleEdgeInsets;
        _labelYOffset = 51;
    }
    return self;
}

- (void)setup {
    [self setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateNormal];
    [self.layer setCornerRadius:self.frame.size.height/2];
    self.layer.masksToBounds = YES;
}

- (void)setLabelTitle:(NSString *)title {
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, _labelYOffset, self.frame.size.width, 21)];
    _label.font = [UIFont systemFontOfSize:12.0];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = title;
    _label.textColor = [UIColor whiteColor];
    
    [self addSubview:_label];
}



@end
