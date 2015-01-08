//
//  TSMassNotificationTableViewCell.m
//  TapShield
//
//  Created by Adam Share on 5/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMassNotificationTableViewCell.h"

@implementation TSMassNotificationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textView.textColor = [TSColorPalette listCellTextColor];
        self.timestampLabel.textColor = [TSColorPalette tapshieldDarkBlue];
        self.backgroundColor = [TSColorPalette cellBackgroundColor];
        self.separatorInset = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
