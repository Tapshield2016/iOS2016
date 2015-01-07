//
//  TSStatusView.m
//  TapShield
//
//  Created by Adam Share on 7/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSStatusView.h"
#import "TSBaseLabel.h"
#import "TSEntourageSessionManager.h"

NSString * const kTSStatusViewApproxAddress = @"Approximate Location";
NSString * const kTSStatusViewTimeRemaining = @"Time Remaining";

@interface TSStatusView ()

@property (strong, nonatomic) TSBaseLabel *label;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIToolbar *statusToolbar;

@end

@implementation TSStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setupViews];
        _statusToolbar.barTintColor = [TSColorPalette alertRed];
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupViews];
        _statusToolbar.barTintColor = [TSColorPalette tapshieldBlue];
    }
    return self;
}

- (void)setupViews {
    _shouldShowRouteInfo = NO;
    
    _statusToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    [_statusToolbar.layer setAffineTransform:CGAffineTransformMakeScale(1, -1)];
    _statusToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    CGRect frame = self.bounds;
    frame.origin.y = frame.size.height*.3 + 1;
    frame.size.height *= .7;
    _label = [[TSBaseLabel alloc] initWithFrame:frame];
    _label.text = @"Searching for location";
    _label.font = [UIFont fontWithName:kFontWeightLight size:18];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor whiteColor];
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    frame = self.bounds;
    frame.origin.y += 1;
    frame.size.height *= .4;
    _titleLabel = [[UILabel alloc] initWithFrame:frame];
    _titleLabel.text = kTSStatusViewApproxAddress;
    _titleLabel.font = [UIFont fontWithName:kFontWeightNormal size:10];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    self.autoresizesSubviews = YES;
    self.backgroundColor = [TSColorPalette clearColor];
    [self addSubview:_statusToolbar];
    [self addSubview:_label];
    [self addSubview:_titleLabel];
    
    _originalHeight = self.frame.size.height;
}

- (void)setUserLocation:(NSString *)userLocation {
    
    _userLocation = userLocation;
    
    if (!_shouldShowRouteInfo) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self setText:userLocation];
        }];
    }
}

- (void)hideText {
    
    
}

- (void)setText:(NSString *)string {
    
    float duration = 0.2;
    if (!string) {
        duration = 0.1;
    }
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = duration;
    [_label.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    
    _label.text = string;
}

- (void)setTitle:(NSString *)title message:(NSString *)message {
    
    float duration = 0.2;
    if (!title) {
        duration = 0.1;
    }
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = duration;
    [_label.layer addAnimation:animation forKey:@"kCATransitionFade"];
    [_titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    
    _label.text = message;
    _titleLabel.text = title;
}


- (void)setShouldShowRouteInfo:(BOOL)shouldShowRouteInfo {
    
    _shouldShowRouteInfo = shouldShowRouteInfo;
    
    if (shouldShowRouteInfo) {
        [self showRouteInfo];
    }
    else {
        [self showUserLocationInfo];
    }
}

- (void)showRouteInfo {
    
    _statusToolbar.barTintColor = nil;
    _label.textColor = [TSColorPalette tapshieldBlue];
    _titleLabel.textColor = [TSColorPalette tapshieldBlue];
    
    NSString *formattedText = [NSString stringWithFormat:@"%@ - %@", [TSUtilities formattedDescriptiveStringForDuration:[TSEntourageSessionManager sharedManager].routeManager.selectedRoute.expectedTravelTime], [TSUtilities formattedStringForDistanceInUSStandard:[TSEntourageSessionManager sharedManager].routeManager.selectedRoute.distanceRemaining]];
    
    MKRouteStep *step = [TSEntourageSessionManager sharedManager].routeManager.selectedRoute.currentStep;
    NSString *title = step.instructions;
    if (!title) {
        title = [TSEntourageSessionManager sharedManager].routeManager.selectedRoute.name;
    }
    
    [self setTitle:title message:formattedText];
}

- (void)showUserLocationInfo {
    
    _statusToolbar.barTintColor = [TSColorPalette tapshieldBlue];
    _label.textColor = [UIColor whiteColor];
    _titleLabel.textColor = [UIColor whiteColor];
    
    [self setTitle:kTSStatusViewApproxAddress message:_userLocation];
}


@end
