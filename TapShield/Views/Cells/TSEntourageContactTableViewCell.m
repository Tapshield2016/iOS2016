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
#import <Shimmer/FBShimmering.h>
#import "TSBaseEntourageContactsTableViewController.h"

#define LeftMargin 10
#define ImageRightMargin 10
#define StatusImageWidth 40
#define ContactImageSize 40
#define LocateButtonWidth 60
#define IndexWidth 15

static NSString * const kDefaultImage = @"user_default_icon";

static NSString * const kTrackingImage = @"entourage_icon";
static NSString * const kAlwaysVisibleImage = @"VisiblePin";
static NSString * const kPhoneNumberImage = @"iPhoneSmall";
static NSString * const kMatchedUserImage = @"TapShieldSmallLogoWhite";
static NSString * const kEmailImage = @"emailSmall";

@interface TSEntourageContactTableViewCell ()

@property (strong, nonatomic) UIView *selectedView;
@property (strong, nonatomic) UIView *highlightedView;

@property (strong, nonatomic) UILabel *startLabel;
@property (strong, nonatomic) UILabel *endLabel;

@property (strong, nonatomic) FBShimmeringView *shimmeringView;

@property (strong, nonatomic) NSTimer *etaTimer;
@property (strong, nonatomic) UILabel *timerLabel;

@property (strong, nonatomic) UIButton *addButton;

@end


@implementation TSEntourageContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _isInEntourage = NO;
        
        _contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LeftMargin, ([TSEntourageContactTableViewCell height] - ContactImageSize)/2, ContactImageSize, ContactImageSize)];
        [self.contentView addSubview:_contactImageView];
        
        
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ContactImageSize+LeftMargin*2, 0, self.frame.size.width - StatusImageWidth - IndexWidth - (ContactImageSize+LeftMargin*2), [TSEntourageContactTableViewCell height])];
        _contactNameLabel.textColor = [UIColor whiteColor];
        _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
        
        
        _shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(self.frame.size.width - StatusImageWidth - IndexWidth, 0, StatusImageWidth, [TSEntourageContactTableViewCell height])];
        _shimmeringView.shimmeringSpeed = 25;
        
        _statusImageView = [[UIImageView alloc] initWithFrame:_shimmeringView.bounds];
        _statusImageView.contentMode = UIViewContentModeCenter;
        _statusImageView.alpha = 0.5;
        _shimmeringView.contentView = _statusImageView;
        
        _timerLabel = [[UILabel alloc] initWithFrame:_shimmeringView.frame];
        _timerLabel.hidden = YES;
        _timerLabel.textColor = [UIColor whiteColor];
        _timerLabel.font = [TSFont fontWithName:kFontWeightThin size:14];
        _timerLabel.textAlignment = NSTextAlignmentCenter;
        _timerLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_timerLabel];
        
        [self.contentView addSubview:_shimmeringView];
        
        [self.contentView addSubview:_contactNameLabel];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.layer.masksToBounds = NO;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    
    return self;
}

- (void)setWidth:(CGFloat)width {
    
    _width = width;
    
    
    _timerLabel.frame = CGRectMake(width - LocateButtonWidth - IndexWidth, 0, LocateButtonWidth, [TSEntourageContactTableViewCell height]);
    
    if (width == [UIScreen mainScreen].bounds.size.width) {
        _contactNameLabel.frame = CGRectMake(ContactImageSize+LeftMargin*2, 0, width - LocateButtonWidth - IndexWidth - (ContactImageSize+LeftMargin*2), [TSEntourageContactTableViewCell height]);
        _shimmeringView.frame = _timerLabel.frame;
        _addButton.frame = _shimmeringView.frame;
    }
    else {
        _contactNameLabel.frame = CGRectMake(ContactImageSize+LeftMargin*2, 0, width - StatusImageWidth - IndexWidth - LeftMargin - ContactImageSize, [TSEntourageContactTableViewCell height]);
        _shimmeringView.frame = CGRectMake(width - StatusImageWidth - IndexWidth, 0, StatusImageWidth, [TSEntourageContactTableViewCell height]);
        _addButton.frame = _shimmeringView.frame;
    }
}

- (void)dimContent {
    _contactImageView.alpha = 0.5;
    _contactNameLabel.alpha = 0.5;
}

- (void)resetAlphas {
    _addButton.hidden = YES;
    _contactImageView.alpha = 1.0;
    _contactNameLabel.alpha = 1.0;
}

+ (CGFloat)selectedHeight {
    
    return 150;
}

+ (CGFloat)height {
    
    return 50;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    if (!self.selected) {
        _shimmeringView.hidden = editing;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    if (!selected && animated) {
        [self displaySelectedView:NO  animated:YES];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    if (_isInEntourage || (!_contact.session && _contact.location)) {
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
        if (_selectedView.hidden) {
            [self removeselectedViewFromSuperview];
        }
        return;
    }
    
    [self initSelectedView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self selectedViewVisible:selected];
    } completion:^(BOOL finished) {
        _selectedView.hidden = !selected;
    }];
}

- (void)removeselectedViewFromSuperview {
    
    [_selectedView removeFromSuperview];
    _selectedView = nil;
}

- (void)selectedViewVisible:(BOOL)visible {
    
    if (visible) {
        _selectedView.frame = CGRectMake(0, [TSEntourageContactTableViewCell height], self.frame.size.width - 15, [TSEntourageContactTableViewCell selectedHeight] - [TSEntourageContactTableViewCell height]);
        _contactNameLabel.frame = CGRectMake(ContactImageSize+LeftMargin*2, 0, self.frame.size.width - LocateButtonWidth - IndexWidth - (ContactImageSize+LeftMargin*2), [TSEntourageContactTableViewCell height]);
        [self startTrackingCountdownTimer];
    }
    else {
        _contactNameLabel.frame = CGRectMake(ContactImageSize+LeftMargin*2, 0, self.frame.size.width - StatusImageWidth - IndexWidth - LeftMargin - ContactImageSize, [TSEntourageContactTableViewCell height]);
        _selectedView.frame = CGRectMake(0, [TSEntourageContactTableViewCell height], self.frame.size.width - 15, 0);
        [self stopTimer];
    }
    
    _shimmeringView.hidden = visible;
    _timerLabel.hidden = !visible;
    [self changeTime];
}

- (void)initSelectedView {
    
    if (_selectedView) {
        _selectedView.hidden = NO;
        return;
    }
    
    [self showTrackingSelectedView];
}

- (void)showTrackingSelectedView {
    
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
    
    _startLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+LeftMargin*2, 0, frame.size.width-110, frame.size.height/2)];
    _startLabel.font = [UIFont fontWithName:kFontWeightThin size:16];
    _startLabel.textColor = [UIColor whiteColor];
    _startLabel.text = _contact.session.startLocation.name;
    [view addSubview:_startLabel];
    
    _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+LeftMargin*2, frame.size.height/2, frame.size.width-110, frame.size.height/2)];
    _endLabel.font = [UIFont fontWithName:kFontWeightThin size:16];
    _endLabel.textColor = [UIColor whiteColor];
    _endLabel.text = _contact.session.endLocation.name;
    [view addSubview:_endLabel];
    
    [self addShimmeringStartEndViewToView:view];
    
//    TSRoundRectButton *button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(frame.size.width-60, 0, 60, frame.size.height);
    [button setBackgroundImage:[UIImage imageFromColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    [button setTitle:@"Locate" forState:UIControlStateNormal];
    
    UIImage *locateImage = [UIImage imageNamed:@"locate_me_icon"];
    [button setImage:[locateImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [button setTitleColor:[TSColorPalette whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(locateUser) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont fontWithName:kFontWeightLight size:14];
    button.titleEdgeInsets = UIEdgeInsetsMake(28, -15, 0, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-28, 17, 0, 0);
    [view addSubview:button];
    
    //TSRoundRectButton *
    UIButton *trackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    trackButton.frame = CGRectMake(0, 0, frame.size.width-61, frame.size.height);
    [trackButton setBackgroundImage:[UIImage imageFromColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    [trackButton addTarget:self action:@selector(trackUser) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:trackButton];
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width-61, 10, 1, frame.size.height-20)];
    borderView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    [view addSubview:borderView];
    
    UIView *horizontalBorderView = [[UIView alloc] initWithFrame:CGRectMake(15+LeftMargin*2, frame.size.height/2, frame.size.width - LocateButtonWidth - (15+LeftMargin*2) - 10, 1)];
    horizontalBorderView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    [view addSubview:horizontalBorderView];
}


- (void)addShimmeringStartEndViewToView:(UIView *)view {
    
    CGRect frame = view.frame;
    
    UIImage *image = [UIImage imageNamed:@"TrackingStartEndPin"];
    float width = image.size.width+20;
    
    FBShimmeringView *shimmerView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(3, 0, width, frame.size.height)];
    shimmerView.shimmeringDirection = FBShimmerDirectionDown;
    shimmerView.shimmeringSpeed = 25;
    [view addSubview:shimmerView];
    
    UIView *contentView = [[UIView alloc] initWithFrame:shimmerView.bounds];
    contentView.backgroundColor = [UIColor clearColor];
    shimmerView.contentView = contentView;
    
    UIImageView *startImageView = [[UIImageView alloc] initWithImage:image];
    startImageView.contentMode = UIViewContentModeCenter;
    startImageView.frame = CGRectMake(0, 0, width, frame.size.height/2);
    [contentView addSubview:startImageView];
    
    UIImageView *endImageView = [[UIImageView alloc] initWithImage:image];
    endImageView.contentMode = UIViewContentModeCenter;
    endImageView.frame = CGRectMake(0, frame.size.height/2, width, frame.size.height/2);
    [contentView addSubview:endImageView];
    
    UIView *dashedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, frame.size.height)];
    
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
    CGPathMoveToPoint(path, NULL, width/2, frame.size.height/3 + 3);
    CGPathAddLineToPoint(path, NULL, width/2, frame.size.height*2/3 - 3);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [[dashedView layer] addSublayer:shapeLayer];
    [contentView addSubview:dashedView];
    
    shimmerView.shimmering = YES;
}

- (void)trackUser {
    
    [[TSEntourageSessionManager sharedManager] showSessionForMember:_contact];
}

- (void)locateUser {
    
    [[TSEntourageSessionManager sharedManager] locateEntourageMember:_contact];
}

- (void)stopTrackingUser {
    
    [[TSEntourageSessionManager sharedManager] removeCurrentMemberSession];
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
    
    [_shimmeringView setShimmering:NO];
    
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
            [_shimmeringView setShimmering:YES];
        }
        else if (contact.location) {
            _statusImageView.image = [UIImage imageNamed:kAlwaysVisibleImage];
        }
        else {
            _statusImageView.image = nil;
        }
    }
    
    _startLabel.text = _contact.session.startLocation.name;
    _endLabel.text = _contact.session.endLocation.name;
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
    
    _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 250, 50)];
    _contactNameLabel.textColor = [UIColor whiteColor];
    _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
    
    [self.contentView addSubview:_contactNameLabel];
    
    _contactNameLabel.text = @"None";
}


- (void)startTrackingCountdownTimer {
    
    [self stopTimer];
    
    _etaTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
    _etaTimer.tolerance = 0.2;
    [[NSRunLoop currentRunLoop] addTimer:_etaTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_etaTimer invalidate];
    _etaTimer = nil;
}

- (void)changeTime {
    NSTimeInterval time = [_contact.session.eta timeIntervalSinceDate:[NSDate date]];
    _timerLabel.text = [TSUtilities formattedStringForTime:time];
    if (time <= 0 && ![_timerLabel.textColor isEqual:[TSColorPalette alertRed]]) {
        _timerLabel.textColor = [TSColorPalette alertRed];
    }
    else if (![_timerLabel.textColor isEqual:[TSColorPalette whiteColor]]) {
        _timerLabel.textColor = [TSColorPalette whiteColor];
    }
}


- (void)addPlusButton:(id)target {
    
    _tableViewController = target;
    
    if (!_addButton) {
        UIImage *image = [UIImage imageNamed:@"plus_icon"];
        
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:image forState:UIControlStateNormal];
        [_addButton setImage:[image imageWithAlpha:0.5] forState:UIControlStateHighlighted];
        [_addButton setFrame:_shimmeringView.frame];
        [self.contentView addSubview:_addButton];
        [_addButton addTarget:self action:@selector(addToEntourage:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        _addButton.hidden = NO;
    }
}

- (IBAction)addToEntourage:(id)sender {
    
    [_tableViewController moveContactToEntourage:self.contact];
}

@end
