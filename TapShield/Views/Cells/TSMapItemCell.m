//
//  TSMapPointCell.m
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUtilities.h"
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

- (void)showDetailsForErrorMessage:(NSError *)error {
    
    _nameLabel.text = @"";
    _addressLabel.text = @"";
    [_pinImageView setHidden:YES];
    
    if (error.code == MKErrorUnknown) {
        _nameLabel.text = @"Unkown error occured.";
    }
    else if (error.code == MKErrorServerFailure) {
        _nameLabel.text = @"Server failed to respond, try again.";
    }
    else if (error.code == MKErrorLoadingThrottled) {
        _nameLabel.text = @"Server throttled requests";
    }
    else if (error.code == MKErrorPlacemarkNotFound) {
        _nameLabel.text = @"No results found.";
    }
}

- (void)showDetailsForMapItem:(MKMapItem *)mapItem {
    
    _nameLabel.text = @"";
    _addressLabel.text = @"";
    
    NSString *address = [TSUtilities formattedAddressWithoutNameFromMapItem:mapItem];
    
    _nameLabel.text = mapItem.name;
    _addressLabel.text = address;
    
    [_pinImageView setHidden:NO];
    if (!address || address.length == 0) {
        [_pinImageView setHidden:YES];
    }
    
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

- (void)boldSearchString:(NSString *)searchString {
    
    CGFloat fontSize = _nameLabel.font.pointSize;
    UIFont *boldFont = [TSRalewayFont fontWithName:kFontRalewayBold size:fontSize];
    UIFont *regularFont = _nameLabel.font;
    UIColor *foregroundColor = _nameLabel.textColor;
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           regularFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              boldFont, NSFontAttributeName,
                              foregroundColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:_nameLabel.text
                                           attributes:attrs];
    
    for (NSString *string in [searchString componentsSeparatedByString:@" "]) {
        if (string.length == 0) {
            continue;
        }
        NSRange range = [[_nameLabel.text lowercaseString] rangeOfString:[string lowercaseString]];
        [attributedText setAttributes:subAttrs range:range];
    }
    [_nameLabel setAttributedText:attributedText];
    
    fontSize = _addressLabel.font.pointSize;
    boldFont = [TSRalewayFont fontWithName:kFontRalewayBold size:fontSize];
    regularFont = _addressLabel.font;
    foregroundColor = _addressLabel.textColor;
    
    attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           regularFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              boldFont, NSFontAttributeName,
                              foregroundColor, NSForegroundColorAttributeName, nil];
    
    if (!_addressLabel.text) {
        return;
    }
    
    attributedText =
    [[NSMutableAttributedString alloc] initWithString:_addressLabel.text
                                           attributes:attrs];
    
    for (NSString *string in [searchString componentsSeparatedByString:@" "]) {
        if (string.length == 0) {
            continue;
        }
        NSRange range = [[_addressLabel.text lowercaseString] rangeOfString:[string lowercaseString]];
        [attributedText setAttributes:subAttrs range:range];
    }
    [_addressLabel setAttributedText:attributedText];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
