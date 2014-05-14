//
//  TSIconBadgeView.h
//  TapShield
//
//  Created by Adam Share on 5/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSColorPalette.h"
#import "TSRalewayFont.h"

@interface TSIconBadgeView : UIView

@property (assign, nonatomic) NSUInteger number;

- (void)setNumber:(NSUInteger)number;
- (void)incrementBadgeNumber;
- (void)clearBadge;

@end
