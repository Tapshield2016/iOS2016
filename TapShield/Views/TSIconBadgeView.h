//
//  TSIconBadgeView.h
//  TapShield
//
//  Created by Adam Share on 5/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSColorPalette.h"
#import "TSFont.h"

@interface TSIconBadgeView : UIView

@property (assign, nonatomic) NSUInteger number;

- (void)setNumber:(NSUInteger)number;
- (void)incrementBadgeNumber;

- (id)initWithFrame:(CGRect)frame observing:(id)object integerKeyPath:(NSString *)keypath;

@end
