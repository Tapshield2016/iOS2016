//
//  UITextField+Selection.h
//  TapShield
//
//  Created by Adam Share on 7/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Selection)

- (NSRange)selectedRange;
- (void)setSelectedRange:(NSRange)range;

@end
