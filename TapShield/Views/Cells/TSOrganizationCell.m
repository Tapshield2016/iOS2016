//
//  TSOrganizationCell.m
//  TapShield
//
//  Created by Adam Share on 2/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSOrganizationCell.h"
#import <KVOController/FBKVOController.h>
#import <UIImageView+AFNetworking.h>

@interface TSOrganizationCell ()

@property (strong, nonatomic) FBKVOController *kvoController;

@end

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
    
    __weak __typeof(self)weakSelf = self;
    [self.logoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:agency.theme.smallLogoUrl]] placeholderImage:[UIImage imageNamed:@"logo_placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (image) {
            strongSelf.logoImageView.image = image;
            strongSelf.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    } failure:nil];
}


@end
