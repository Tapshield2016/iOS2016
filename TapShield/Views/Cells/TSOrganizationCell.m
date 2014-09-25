//
//  TSOrganizationCell.m
//  TapShield
//
//  Created by Adam Share on 2/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSOrganizationCell.h"

@implementation TSOrganizationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_placeholder"]];
        self.logoImageView.contentMode = UIViewContentModeCenter;
        self.logoImageView.center = CGPointMake(20, 20);
        
        self.organizationLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(40.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 40.0f)];
        self.organizationLabel.font = [TSFont fontWithName:kFontWeightLight size:15.0f];
        self.organizationLabel.textColor = [TSColorPalette listCellTextColor];
        
        [self addSubview:self.logoImageView];
        [self addSubview:self.organizationLabel];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAgency:(TSJavelinAPIAgency *)agency {
    
    _agency = agency;
    
    _organizationLabel.text = agency.name;
    
    UIImage *image = agency.smallLogo;
    if (image) {
        self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else {
        image = [UIImage imageNamed:@"logo_placeholder"];
        self.logoImageView.contentMode = UIViewContentModeCenter;
    }
    
    self.logoImageView.image = image;
}


@end
