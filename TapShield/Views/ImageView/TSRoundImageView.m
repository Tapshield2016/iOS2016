//
//  TSRoundImageView.m
//  TapShield
//
//  Created by Adam Share on 4/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRoundImageView.h"

@implementation TSRoundImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.layer.cornerRadius = frame.size.height/2;
        self.layer.masksToBounds = YES;
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        self.layer.cornerRadius = self.frame.size.height/2;
        self.layer.masksToBounds = YES;
    }
    return self;
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
