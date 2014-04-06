//
//  TSMapPointCell.m
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMapItemCell.h"

@implementation TSMapItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.addressLabel = [[TSBaseLabel alloc] init];
        self.nameLabel = [[TSBaseLabel alloc] init];
        self.pinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pointer_icon"]];
        self.pinImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.addressLabel];
        [self addSubview:self.nameLabel];
        [self addSubview:self.pinImageView];
        
        UIView *selectedView = [[UIView alloc] initWithFrame:self.frame];
        selectedView.backgroundColor = [TSColorPalette whiteColor];
        self.selectedBackgroundView = selectedView;
        self.backgroundColor = [TSColorPalette cellBackgroundColor];
        self.nameLabel.font = [TSRalewayFont fontWithName:kFontRalewayLight size:16.0f];
        self.nameLabel.textColor = [TSColorPalette listCellTextColor];
        self.nameLabel.numberOfLines = 1;
        self.addressLabel.font = [TSRalewayFont fontWithName:kFontRalewayLight size:10.0f];
        self.addressLabel.textColor = [TSColorPalette listCellDetailsTextColor];
        self.addressLabel.numberOfLines = 1;

        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
    }
    return self;
}

- (void)showDetailsForMapItem:(MKMapItem *)mapItem {
    
    _nameLabel.text = @"";
    _addressLabel.text = @"";
    
    NSArray *formattedAddressLines = mapItem.placemark.addressDictionary[@"FormattedAddressLines"];
    NSString *address;
    
    for (NSString *string in formattedAddressLines) {
        
        if ([string isEqualToString:mapItem.name]) {
            continue;
        }
        
        if (!address) {
            address = string;
            continue;
        }
        
        if ([string isEqualToString:mapItem.placemark.country]) {
            continue;
        }
        
        address = [NSString stringWithFormat:@"%@ %@", address, string];
    }
    
    _nameLabel.text = mapItem.name;
    _addressLabel.text = address;
    
    CGRect nameFrame;
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          _nameLabel.font, NSFontAttributeName,
                                          nil];
    
    CGRect frame = [_nameLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height/2)
                                            options:NSStringDrawingTruncatesLastVisibleLine
                                         attributes:attributesDictionary
                                            context:nil];
    nameFrame.size = frame.size;
    nameFrame.origin.y = self.frame.size.height/2 - frame.size.height + 2;
    nameFrame.origin.x = self.frame.size.width/30;
    nameFrame.size.width = self.frame.size.width*27/30;
    _nameLabel.frame = nameFrame;
    
    CGRect addressFrame;
    addressFrame = nameFrame;
    addressFrame.origin.y = self.frame.size.height/2;
    
    CGRect pinFrame;
    pinFrame = addressFrame;
    
    addressFrame.origin.x += _pinImageView.frame.size.width*2.0;
    addressFrame.size.width -= _pinImageView.frame.size.width*2.0;
    _addressLabel.frame = addressFrame;
    
    pinFrame.origin.y += 1;
    pinFrame.origin.x += _pinImageView.frame.size.width/2;
    pinFrame.size.width = _pinImageView.frame.size.width;
    _pinImageView.frame = pinFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
