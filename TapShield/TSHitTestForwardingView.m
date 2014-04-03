//
//  TSHitTestForwardingView.m
//  TapShield
//
//  Created by Adam Share on 3/31/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHitTestForwardingView.h"

@implementation TSHitTestForwardingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (_sendToView) {
        //pass hit test on to the identical view attached to keyboard
        hitView = [_sendToView hitTest:point withEvent:event];
    }
    
    return hitView;
}
@end
