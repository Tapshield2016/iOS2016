//
//  TSAddPhoneNumberCell.m
//  TapShield
//
//  Created by Adam Share on 12/14/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAddPhoneNumberCell.h"

@interface TSAddPhoneNumberCell ()

@property (strong, nonatomic) UIView *highlightedView;

@end

@implementation TSAddPhoneNumberCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.layer.masksToBounds = NO;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        
        [self addViews];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    [self displayHighlightedView:highlighted];
}

- (void)displayHighlightedView:(BOOL)highlighted {
    
    CGRect frame = CGRectMake(0, 0, self.frame.size.width - 15, self.frame.size.height);
    
    if (!_highlightedView) {
        _highlightedView = [[UIView alloc] initWithFrame:frame];
        _highlightedView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        [self.contentView insertSubview:_highlightedView atIndex:0];
    }
    else {
        _highlightedView.frame = frame;
    }
    
    _highlightedView.hidden = !highlighted;
}

- (void)addViews {
    
    float height = 80;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FindMyBlue"]];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.frame = CGRectMake(10, 0, 40, 80);
    imageView.alpha = 0.8;
    [self.contentView addSubview:imageView];
    
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
    
    UILabel *phoneNumberRequiredLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    phoneNumberRequiredLabel.text = @"Find my friends and family on TapShield";
    phoneNumberRequiredLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    phoneNumberRequiredLabel.font = [UIFont fontWithName:kFontWeightLight size:16];
    phoneNumberRequiredLabel.frame = CGRectMake(imageView.frame.size.width + imageView.frame.origin.x*2, 0, 150, height);
    phoneNumberRequiredLabel.numberOfLines = 2;
    [self.contentView addSubview:phoneNumberRequiredLabel];
    
}

@end
