//
//  UIView+FirstResponder.m
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "UIView+FirstResponder.h"

@implementation UIView (FirstResponder)

- (UIView *)findFirstResponder {
    if ([self isFirstResponder])
        return self;
    
    for (UIView * subView in self.subviews) {
        UIView * firstResponder = [subView findFirstResponder];
        if (firstResponder != nil)
            return firstResponder;
    }
    
    return nil;
}

@end
