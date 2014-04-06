//
//  TSMapPointCell.h
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewCell.h"
#import <MapKit/MapKit.h>

@interface TSMapItemCell : TSBaseTableViewCell

@property (strong, nonatomic) TSBaseLabel *nameLabel;
@property (strong, nonatomic) TSBaseLabel *addressLabel;

- (void)showDetailsForMapItem:(MKMapItem *)mapItem;

@end
