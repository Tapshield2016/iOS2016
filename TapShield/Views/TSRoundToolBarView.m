//
//  TSRoundToolBarView.m
//  TapShield
//
//  Created by Adam Share on 4/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRoundToolBarView.h"

@implementation TSRoundToolBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        
        self.layer.cornerRadius = self.frame.size.width/2;
        self.layer.masksToBounds = YES;
    }
    return self;
}


@end
