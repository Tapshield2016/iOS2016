//
//  TSAddMemberCell.m
//  TapShield
//
//  Created by Adam Share on 4/23/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAddMemberCell.h"

@implementation TSAddMemberCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)addButtonTarget:(id)target action:(SEL)selector {
    
    [_button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
