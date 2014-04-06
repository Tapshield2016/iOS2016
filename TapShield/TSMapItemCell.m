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
        [self.view adds]
        
        UIView *selectedView = [[UIView alloc] initWithFrame:self.frame];
        selectedView.backgroundColor = [TSColorPalette whiteColor];
        self.selectedBackgroundView = selectedView;
        self.backgroundColor = [TSColorPalette cellBackgroundColor];
        self.nameLabel.font = [TSRalewayFont fontWithName:kFontRalewayLight size:16.0f];
        self.nameLabel.textColor = [TSColorPalette listCellTextColor];
        self.addressLabel.font = [TSRalewayFont fontWithName:kFontRalewayLight size:10.0f];
        self.addressLabel.textColor = [TSColorPalette listCellDetailsTextColor];
    }
    return self;
}

- (void)showDetailsForMapItem:(MKMapItem *)mapItem {
    
    _nameLabel.text = mapItem.name;
    _addressLabel.text = mapItem.placemark.addressDictionary[@"Street"];
    
    CGRect nameFrame;
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          _nameLabel.font, NSFontAttributeName,
                                          nil];
    
    CGRect frame = [_nameLabel.text boundingRectWithSize:CGSizeMake(263, 2000.0)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributesDictionary
                                            context:nil];
    nameFrame.size = frame.size;
    nameFrame.origin.y = self.frame.size.height/2 - frame.size.height;
    nameFrame.origin.x = self.frame.size.width/10;
    _nameLabel.frame = nameFrame;
    
    CGRect addressFrame;
    attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          _addressLabel.font, NSFontAttributeName,
                                          nil];
    
    frame = [_addressLabel.text boundingRectWithSize:CGSizeMake(263, 2000.0)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:attributesDictionary
                                                 context:nil];
    addressFrame.size = frame.size;
    addressFrame.origin.y = self.frame.size.height/2;
    addressFrame.origin.x = self.frame.size.width/10;
    _addressLabel.frame = addressFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
