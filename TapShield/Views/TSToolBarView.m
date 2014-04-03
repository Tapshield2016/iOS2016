//
//  TSToolBarView.m
//  TapShield
//
//  Created by Adam Share on 3/30/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSToolBarView.h"

@implementation TSToolBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self addToolbarBackground];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self addToolbarBackground];
    }
    return self;
}

- (void)addToolbarBackground {
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:_toolbar atIndex:0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
