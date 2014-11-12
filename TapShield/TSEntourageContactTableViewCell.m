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

static NSString * const kTrackingImage = @"entourage_icon";
static NSString * const kAlwaysVisibleImage = @"VisiblePin";
static NSString * const kPhoneNumberImage = @"iPhoneSmall";
static NSString * const kMatchedUserImage = @"TapShieldSmallLogoWhite";
static NSString * const kEmailImage = @"emailSmall";

@interface TSEntourageContactTableViewCell ()

@property (strong, nonatomic) UIView *selectedView;
@property (strong, nonatomic) UIView *highlightedView;

@end


@implementation TSEntourageContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _isInEntourage = NO;
        
        _contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 40, 40)];
        [self.contentView addSubview:_contactImageView];
        
        
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 145, 50)];
        _contactNameLabel.textColor = [UIColor whiteColor];
        _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
        
        _statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(215, 0, 40, 50)];
        _statusImageView.contentMode = UIViewContentModeCenter;
        _statusImageView.alpha = 0.5;
        
        _statusImageView.image = [UIImage imageNamed:kTrackingImage];
        [self.contentView addSubview:_statusImageView];
        
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
    
    [super setSelected:selected animated:animated];
    
    if (!selected) {
        [self displaySelectedView:NO];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    if (_isInEntourage) {
        [self displayHighlightedView:highlighted];
    }
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

- (void)displaySelectedView:(BOOL)selected {
    
    if (!selected && !_selectedView) {
        return;
    }
    
    [self initSelectedView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self selectedViewVisible:selected];
    } completion:^(BOOL finished) {
        _selectedView.hidden = !selected;
    }];
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
    [self.contentView insertSubview:_selectedView atIndex:0];
    
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
    
    TSRoundRectButton *button = [[TSRoundRectButton alloc] initWithFrame:CGRectMake(10, 10, 120, 50)];
    [button setTitle:@"Invite" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(10, 70, 200, 50);
    [button2 setTitle:@"Prefrences" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(pressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button2];
}

- (void)pressed {
    NSLog(@"Pressed");
}

- (void)setContact:(TSJavelinAPIEntourageMember *)contact {
    
    _contact = contact;
    
    [self initContentSubviews];
    
    if (contact.image) {
        _contactImageView.image = contact.image;
    }
    else {
        _contactImageView.image = [UIImage imageNamed:kDefaultImage];
    }
    _contactNameLabel.text = contact.name;
    
    if (contact.matchedUser) {
        _statusImageView.image = [UIImage imageNamed:kMatchedUserImage];
    }
    else if (contact.phoneNumber) {
        _statusImageView.image = [UIImage imageNamed:kPhoneNumberImage];
    }
    else if (contact.email) {
        _statusImageView.image = [UIImage imageNamed:kEmailImage];
    }
    
    
    if (!_isInEntourage) {
        if (contact.session) {
            _statusImageView.image = [UIImage imageNamed:kTrackingImage];
        }
        else if (contact.lastReportedLocation) {
            _statusImageView.image = [UIImage imageNamed:kAlwaysVisibleImage];
        }
    }
}

- (void)initContentSubviews {
    
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
}

- (void)emptyCell {
    
    [_contactNameLabel removeFromSuperview];
    [_contactImageView removeFromSuperview];
    
    _statusImageView.hidden = YES;
    
    _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 250, 50)];
    _contactNameLabel.textColor = [UIColor whiteColor];
    _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
    
    [self.contentView addSubview:_contactNameLabel];
    
    _contactNameLabel.text = @"None";
}

@end
