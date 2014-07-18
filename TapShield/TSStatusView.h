//
//  TSStatusView.h
//  TapShield
//
//  Created by Adam Share on 7/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSStatusView : UIView

@property (assign, nonatomic) float originalHeight;
@property (strong, nonatomic) NSString *userLocation;

- (void)setText:(NSString *)string;

- (id)initWithFrame:(CGRect)frame;

@end
