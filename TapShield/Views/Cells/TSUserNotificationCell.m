//
//  TSUserNotificationCell.m
//  TapShield
//
//  Created by Adam Share on 11/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserNotificationCell.h"
#import "NSDate+Utilities.h"

@interface TSUserNotificationCell ()

@property (strong, nonatomic) UIView *unreadView;
@property (strong, nonatomic) UIView *borderView;
@property (strong, nonatomic) UIView *highlightedView;

@end

@implementation TSUserNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.textLabel.font = [UIFont fontWithName:kFontWeightLight size:14];
        self.textLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.font = [UIFont fontWithName:kFontWeightLight size:10];
        self.detailTextLabel.textColor = [UIColor lightTextColor];
        
        self.textLabel.numberOfLines = 3;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _borderView = [[UIView alloc] initWithFrame:CGRectZero];
        _borderView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        [self.contentView addSubview:_borderView];
        
        _unreadView = [[UIView alloc] initWithFrame:CGRectZero];
        _unreadView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        [self.contentView addSubview:_unreadView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
    if (selected) {
        [self markRead];
    }
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    [self displayHighlightedView:highlighted];
}

- (void)displayHighlightedView:(BOOL)highlighted {
    
    CGRect frame = CGRectMake(0, 0, self.frame.size.width - 15, self.frame.size.height);
    
    if (!_highlightedView) {
        _highlightedView = [[UIView alloc] initWithFrame:frame];
        _highlightedView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        [self.contentView insertSubview:_highlightedView atIndex:0];
    }
    else {
        _highlightedView.frame = frame;
    }
    
    _highlightedView.hidden = !highlighted;
}


- (void)setNotification:(TSJavelinAPIUserNotification *)notification {
    
    _notification = notification;
    
    self.textLabel.text = notification.message;
    self.detailTextLabel.text = [notification.creationDate dateDescriptionSinceNow];
    
    if (!notification.read) {
        [_unreadView setHidden:NO];
    }
    else {
        [_unreadView setHidden:YES];
    }
}

- (void)markRead {
    
    if (_notification.read) {
        return;
    }
    
    [[TSJavelinPushNotificationManager sharedManager] readNotification:_notification completion:nil];
    [_unreadView setHidden:YES];
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    float offset = [(UITableView *)self.superview contentOffset].x;
    if (offset && !self.frame.origin.x) {
        [self markRead];
    }
    else if (!_notification.read) {
        [_unreadView setHidden:NO];
    }
    
    _borderView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 0.5);
    _unreadView.frame = CGRectMake(0, 0.5, self.contentView.frame.size.width, self.contentView.frame.size.height-0.5);
}


@end
