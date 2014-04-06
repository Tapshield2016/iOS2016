//
//  TSUserProfileCell.m
//  TapShield
//
//  Created by Adam Share on 2/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserProfileCell.h"

@implementation TSUserProfileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSLog(@"%f", self.frame.size.height);
        
    }
    return self;
}

- (void)setUser:(TSJavelinAPIUser *)user {
    _user = user;
    
    _profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/20, self.frame.size.height/10, self.frame.size.height * 6/10, self.frame.size.height * 6/10)];
    _profileImageView.image = [UIImage imageNamed:@"no_image"];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_profileImageView.frame.origin.x * 2 + _profileImageView.frame.size.width, _profileImageView.frame.origin.y, self.frame.size.width - _profileImageView.frame.size.width + _profileImageView.frame.origin.x * 3, 20.0f)];
    _nameLabel.clipsToBounds = NO;
    _nameLabel.textColor = [TSColorPalette whiteColor];
    
    _organizationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_profileImageView.frame.origin.x * 2 + _profileImageView.frame.size.width, _profileImageView.frame.origin.y + 30, self.frame.size.width - _profileImageView.frame.size.width + _profileImageView.frame.origin.x * 3, 20.0f)];
    _organizationLabel.clipsToBounds = NO;
    _organizationLabel.textColor = [TSColorPalette whiteColor];
    
    [self addSubview:_profileImageView];
    [self addSubview:_nameLabel];
    [self addSubview:_organizationLabel];
    
    if (user.userProfile.profileImage) {
        _profileImageView.image = user.userProfile.profileImage;
    }
    _nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    _organizationLabel.text = user.agency.name;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
