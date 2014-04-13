//
//  TSRoundUserImageView.m
//  TapShield
//
//  Created by Adam Share on 4/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRoundUserImageView.h"

@implementation TSRoundUserImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"default_user_icon"];
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
