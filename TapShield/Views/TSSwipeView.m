//
//  TSSwipeView.m
//  TapShield
//
//  Created by Adam Share on 8/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSwipeView.h"
#import "TSBaseLabel.h"
#import "FBShimmeringView.h"

@implementation TSSwipeView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.bounds];
    shimmeringView.shimmeringDirection = FBShimmerDirectionLeft;
    shimmeringView.shimmeringSpeed = 150;
    shimmeringView.backgroundColor = [UIColor clearColor];
    [self addSubview:shimmeringView];
    
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipe_arrows_icon"]];
    imageView.contentMode = UIViewContentModeRight;
    CGRect frame = view.bounds;
    frame.origin.y += 1;
    imageView.frame = frame;
    
    TSBaseLabel *label = [[TSBaseLabel alloc] initWithFrame:view.bounds];
    label.textColor = [UIColor whiteColor];
    label.text = @"Swipe screen";
    label.font = [UIFont fontWithName:kFontRalewayRegular size:18.0];
    
    [view addSubview:label];
    [view addSubview:imageView];
    
    [shimmeringView setContentView:view];
    shimmeringView.shimmering = YES;
}

@end
