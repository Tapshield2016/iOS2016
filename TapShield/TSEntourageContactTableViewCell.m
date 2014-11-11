//
//  TSEntourageContactTableViewCell.m
//  TapShield
//
//  Created by Adam Share on 10/25/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageContactTableViewCell.h"
#import "TSFont.h"
#import "TSRoundRectButton.h"
#import "TSEntourageMemberSettingsViewController.h"

static NSString * const kDefaultImage = @"user_default_icon";

@interface TSEntourageContactTableViewCell ()

@property (strong, nonatomic) UIView *selectedView;

@end


@implementation TSEntourageContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 40, 40)];
        [self.contentView addSubview:_contactImageView];
        
        
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 50)];
        _contactNameLabel.textColor = [UIColor whiteColor];
        _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
        
        [self.contentView addSubview:_contactNameLabel];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.layer.masksToBounds = NO;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    
    return self;
}

+ (CGFloat)selectedHeight {
    
    return 200;
}

+ (CGFloat)height {
    
    return 50;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    if (self.selected == selected) {
        [super setSelected:selected animated:animated];
        return;
    }
    
    [super setSelected:selected animated:animated];
    
//    [self initSelectedView];
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        [self selectedViewVisible:selected];
//    } completion:^(BOOL finished) {
//        _selectedView.hidden = !selected;
//    }];
}

- (void)selectedViewVisible:(BOOL)visible {
    
    if (visible) {
        _selectedView.frame = CGRectMake(0, [TSEntourageContactTableViewCell height], self.frame.size.width - 15, [TSEntourageContactTableViewCell selectedHeight] - [TSEntourageContactTableViewCell height]);
    }
    else {
        _selectedView.frame = CGRectMake(0, [TSEntourageContactTableViewCell height], self.frame.size.width - 15, 0);
    }
}

- (void)initSelectedView {
    
    if (_selectedView) {
        _selectedView.hidden = NO;
        return;
    }
    
    CGRect frame = CGRectMake(0, [TSEntourageContactTableViewCell height], self.frame.size.width - 15, 0);
    _selectedView = [[UIView alloc] initWithFrame:frame];
    _selectedView.backgroundColor = [UIColor clearColor];
    _selectedView.clipsToBounds = YES;
    [self insertSubview:_selectedView atIndex:0];
    
    frame.origin.y = 0;
    frame.size.height = [TSEntourageContactTableViewCell selectedHeight] - [TSEntourageContactTableViewCell height];
//    UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];//[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
//    vibrancyView.frame = frame;
//    [_selectedView addSubview:vibrancyView];
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [_selectedView addSubview:view];
    
    CALayer *innerShadowLayer = [[CALayer alloc]init];
    innerShadowLayer.frame = CGRectMake(0, -2, _selectedView.frame.size.width+15, 2);
    innerShadowLayer.backgroundColor = [UIColor whiteColor].CGColor;
    innerShadowLayer.masksToBounds = NO;
    innerShadowLayer.shadowOffset = CGSizeMake(0, 3);
    innerShadowLayer.shadowRadius = 5;
    innerShadowLayer.shadowOpacity = 1.0;
    innerShadowLayer.shadowColor = [UIColor blackColor].CGColor;
    
    [_selectedView.layer addSublayer:innerShadowLayer];
    
    TSRoundRectButton *button = [[TSRoundRectButton alloc] initWithFrame:CGRectMake(10, 10, 70, 50)];
    [button setTitle:@"Prefrences" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(presentMemberSettings) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

- (void)setContact:(TSJavelinAPIEntourageMember *)contact {
    
    if (!_contactImageView.superview) {
        
        [_contactNameLabel removeFromSuperview];
        [_contactImageView removeFromSuperview];
        
        _contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 40, 40)];
        [self.contentView addSubview:_contactImageView];
        
        
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 50)];
        _contactNameLabel.textColor = [UIColor whiteColor];
        _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
        
        [self.contentView addSubview:_contactNameLabel];
    }
    
    _contact = contact;
    
    if (contact.image) {
        _contactImageView.image = contact.image;
    }
    else {
        _contactImageView.image = [UIImage imageNamed:kDefaultImage];
    }
    _contactNameLabel.text = contact.name;
}

- (void)emptyCell {
    
    [_contactNameLabel removeFromSuperview];
    [_contactImageView removeFromSuperview];
    
    _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 250, 50)];
    _contactNameLabel.textColor = [UIColor whiteColor];
    _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
    
    [self.contentView addSubview:_contactNameLabel];
    
    _contactNameLabel.text = @"None";
}

@end
