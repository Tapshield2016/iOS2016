//
//  TSSelectedDestinationLeftCalloutAccessoryView.m
//  TapShield
//
//  Created by Ben Boyd on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSelectedDestinationLeftCalloutAccessoryView.h"

@implementation TSSelectedDestinationLeftCalloutAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {

    _etaLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 5, 41, 20)];
    _etaLabel.font = [UIFont systemFontOfSize:16.0];
    _etaLabel.textAlignment = NSTextAlignmentCenter;
    _etaLabel.backgroundColor = [UIColor clearColor];
    _etaLabel.textColor = [UIColor whiteColor];
    _etaLabel.text = @"ETA";
    [self addSubview:_etaLabel];

    _minutes = [[UILabel alloc] initWithFrame:CGRectMake(2, 20, 41, 20)];
    _minutes.font = [UIFont systemFontOfSize:14.0];
    _minutes.textAlignment = NSTextAlignmentCenter;
    _minutes.backgroundColor = [UIColor clearColor];
    _minutes.textColor = [UIColor whiteColor];
    _minutes.adjustsFontSizeToFitWidth = YES;
    _minutes.text = @"";
    [self addSubview:_minutes];
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
