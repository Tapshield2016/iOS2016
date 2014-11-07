//
//  TSEntourageContactTableViewCell.m
//  TapShield
//
//  Created by Adam Share on 10/25/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageContactTableViewCell.h"
#import "TSFont.h"

static NSString * const kDefaultImage = @"user_default_icon";


@implementation TSEntourageContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 40, 40)];
        [self.contentView addSubview:_contactImageView];
        
        
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 50)];
        _contactNameLabel.textColor = [UIColor whiteColor];
        _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
        
        [self.contentView addSubview:_contactNameLabel];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.layer.masksToBounds = NO;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContact:(TSJavelinAPIEntourageMember *)contact {
    
    if (!_contactImageView.superview) {
        
        [_contactNameLabel removeFromSuperview];
        [_contactImageView removeFromSuperview];
        
        _contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 40, 40)];
        [self.contentView addSubview:_contactImageView];
        
        
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 50)];
        _contactNameLabel.textColor = [UIColor whiteColor];
        _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
        
        [self.contentView addSubview:_contactNameLabel];
    }
    
    _contact = contact;
    
    if (contact.image) {
        _contactImageView.image = contact.image;
    }
    else {
        _contactImageView.image = [UIImage imageNamed:kDefaultImage];
    }
    _contactNameLabel.text = contact.name;
}

- (void)emptyCell {
    
    [_contactNameLabel removeFromSuperview];
    [_contactImageView removeFromSuperview];
    
    _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 250, 50)];
    _contactNameLabel.textColor = [UIColor whiteColor];
    _contactNameLabel.font = [TSFont fontWithName:kFontWeightThin size:16];
    
    [self.contentView addSubview:_contactNameLabel];
    
    _contactNameLabel.text = @"None";
}

- (void)setFrame:(CGRect)frame {
    
    frame.size.width = self.superview.frame.size.width - 15;
    [super setFrame:frame];
}

@end
