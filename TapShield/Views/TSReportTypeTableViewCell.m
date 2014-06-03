//
//  TSReportTypeTableViewCell.m
//  TapShield
//
//  Created by Adam Share on 6/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSReportTypeTableViewCell.h"

@implementation TSReportTypeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        _typeImageView.layer.cornerRadius = _typeImageView.frame.size.width/2;
        _typeImageView.layer.borderColor = [TSColorPalette tapshieldBlue].CGColor;
        _typeImageView.layer.borderWidth = 1.0f;
        _typeImageView.contentMode = UIViewContentModeCenter;
        
        _typeLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:18.0f];
        _typeLabel.textColor = [TSColorPalette listCellTextColor];
        self.backgroundColor = [TSColorPalette cellBackgroundColor];
    }
    return self;
}

- (void)setTypeForRow:(int)row {
    
    _typeImageView.layer.cornerRadius = _typeImageView.frame.size.width/2;
    _typeImageView.layer.borderColor = [TSColorPalette tapshieldBlue].CGColor;
    _typeImageView.layer.borderWidth = 1.0f;
    _typeImageView.contentMode = UIViewContentModeCenter;
    
    _typeLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:18.0f];
    _typeLabel.textColor = [TSColorPalette listCellTextColor];
    self.backgroundColor = [TSColorPalette cellBackgroundColor];
    
    _typeLabel.text = [[NSArray arrayWithObjects:kSocialCrimeReportLongArray] objectAtIndex:row];
    _typeImageView.image = [TSReportTypeTableViewCell imageForType:row];
}

+ (UIImage *)imageForType:(SocialReportTypes)type {
    
    NSString *string = [[NSArray arrayWithObjects:kSocialCrimeReportLongArray] objectAtIndex:type];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *imageName = [NSString stringWithFormat:@"bubble_%@_icon", [string lowercaseString]];
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        image = [UIImage imageNamed:@"bubble_other_icon"];
    }
    
    return image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
