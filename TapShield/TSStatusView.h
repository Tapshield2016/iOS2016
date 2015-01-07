//
//  TSStatusView.h
//  TapShield
//
//  Created by Adam Share on 7/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kTSStatusViewApproxAddress;
extern NSString * const kTSStatusViewTimeRemaining;

@interface TSStatusView : UIView

@property (assign, nonatomic) float originalHeight;
@property (strong, nonatomic) NSString *userLocation;

@property (assign, nonatomic) BOOL shouldShowRouteInfo;

- (void)setText:(NSString *)string;

- (id)initWithFrame:(CGRect)frame;
- (void)setTitle:(NSString *)title message:(NSString *)message;

- (void)showRouteInfo;

@end
