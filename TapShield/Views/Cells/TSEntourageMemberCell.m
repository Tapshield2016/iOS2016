//
//  TSEntourageMemberCell.m
//  TapShield
//
//  Created by Adam Share on 4/23/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageMemberCell.h"
#import "TSNotifySelectionViewController.h"
#import "UIImage+Resize.h"

static NSString * const kSelectedImage = @"user_tick_icon";
static NSString * const kDefaultImage = @"user_default_icon";

@implementation TSEntourageMemberCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)setMember:(TSJavelinAPIEntourageMember *)member {
    
    _member = member;
    
    CGRect frame = _button.frame;
    [_button removeFromSuperview];
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = frame;
    
    UIImage *userImage = [UIImage imageNamed:kDefaultImage];
    if (member.image) {
        userImage = [member.image imageWithRoundedCornersRadius:member.image.size.height/2];
    }
    [_button setBackgroundImage:userImage forState:UIControlStateNormal];
    [_button setImage:[UIImage imageNamed:kSelectedImage] forState:UIControlStateSelected];
    [_button addTarget:self action:@selector(buttonSelected) forControlEvents:UIControlEventTouchUpInside];
    _button.selected = YES;
    [self addSubview:_button];
    
    _label.text = member.name;
}

- (void)addButtonTarget:(id)target action:(SEL)selector {
    _target = target;
}

- (void)buttonSelected {
    
    _button.selected = !_button.selected;
    
    if ([_target respondsToSelector:@selector(addOrRemoveMember:)]) {
        [_target performSelector:@selector(addOrRemoveMember:) withObject:self];
    }
}


@end
