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
#import "TSEntourageSessionManager.h"

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
    
    return 150;
}

+ (CGFloat)height {
    
    return 50;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    if (!selected && animated) {
        [self displaySelectedView:NO  animated:YES];
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

- (void)displaySelectedView:(BOOL)selected animated:(BOOL)animated {
    
    if (!selected && !_selectedView) {
        return;
    }
    
    if (!animated) {
        [self initSelectedView];
        [self selectedViewVisible:selected];
        _selectedView.hidden = !selected;
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
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width-61, 10, 1, frame.size.height-20)];
    borderView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    [view addSubview:borderView];
    
    UIImageView *startImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrackingStartEndPin"]];
    startImageView.contentMode = UIViewContentModeCenter;
    startImageView.frame = CGRectMake(0, 0, 40, frame.size.height/2);
    [view addSubview:startImageView];
    
    UIImageView *endImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrackingStartEndPin"]];
    endImageView.contentMode = UIViewContentModeCenter;
    endImageView.frame = CGRectMake(0, frame.size.height/2, 40, frame.size.height/2);
    [view addSubview:endImageView];
    
    UIView *dashedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, frame.size.height)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:dashedView.bounds];
    [shapeLayer setPosition:dashedView.center];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[TSColorPalette tapshieldBlue] CGColor]];
    [shapeLayer setLineWidth:2.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:5],
      [NSNumber numberWithInt:6],nil]];
    
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 20, frame.size.height/3 + 3);
    CGPathAddLineToPoint(path, NULL, 20, frame.size.height*2/3 - 3);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [[dashedView layer] addSublayer:shapeLayer];
    [view addSubview:dashedView];
    
    
    UIView *horizontalBorderView = [[UIView alloc] initWithFrame:CGRectMake(40, frame.size.height/2, frame.size.width-110, 1)];
    horizontalBorderView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    [view addSubview:horizontalBorderView];
    
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, frame.size.width-110, frame.size.height/2)];
    startLabel.font = [UIFont fontWithName:kFontWeightThin size:16];
    startLabel.textColor = [UIColor whiteColor];
    startLabel.text = _contact.session.startLocation.name;
    [view addSubview:startLabel];
    
    UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, frame.size.height/2, frame.size.width-110, frame.size.height/2)];
    endLabel.font = [UIFont fontWithName:kFontWeightThin size:16];
    endLabel.textColor = [UIColor whiteColor];
    endLabel.text = _contact.session.endLocation.name;
    [view addSubview:endLabel];
    
    
    TSRoundRectButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(frame.size.width-60, 0, 60, frame.size.height);
    [button setBackgroundImage:[UIImage imageFromColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    [button setTitle:@"Locate" forState:UIControlStateNormal];
    
    UIImage *locateImage = [UIImage imageNamed:@"locate_me_icon"];
    [button setImage:[locateImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [button setTitleColor:[TSColorPalette whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(locateUser) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont fontWithName:kFontWeightLight size:16];
    button.titleEdgeInsets = UIEdgeInsetsMake(28, -17, 0, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-28, 17, 0, 0);
    [view addSubview:button];
}


- (void)locateUser {
    
    [[TSEntourageSessionManager sharedManager] locateEntourageMember:_contact];
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
    
    
    if (_isInEntourage) {
        if (contact.matchedUser) {
            _statusImageView.image = [UIImage imageNamed:kMatchedUserImage];
        }
        else if (contact.phoneNumber) {
            _statusImageView.image = [UIImage imageNamed:kPhoneNumberImage];
        }
        else if (contact.email) {
            _statusImageView.image = [UIImage imageNamed:kEmailImage];
        }
    }
    else {
        if (contact.session) {
            _statusImageView.image = [UIImage imageNamed:kTrackingImage];
        }
        else if (contact.location) {
            _statusImageView.image = [UIImage imageNamed:kAlwaysVisibleImage];
        }
        else {
            _statusImageView.image = nil;
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
