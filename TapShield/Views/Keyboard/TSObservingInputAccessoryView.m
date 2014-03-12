//
//  TSObservingInputAccessoryView.m
//  TapShield
//
//  Created by Adam Share on 3/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSObservingInputAccessoryView.h"

NSString * const TSObservingInputAccessoryViewSuperviewFrameDidChangeNotification = @"TSObservingInputAccessoryViewSuperviewFrameDidChangeNotification";


@implementation TSObservingInputAccessoryView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview) {
        [self.superview removeObserver:self
                            forKeyPath:@"frame"];
    }
    
    [newSuperview addObserver:self
                   forKeyPath:@"frame"
                      options:0
                      context:NULL];
    
    [super willMoveToSuperview:newSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.superview && [keyPath isEqualToString:@"frame"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TSObservingInputAccessoryViewSuperviewFrameDidChangeNotification
                                                            object:self];
    }
}

@end
