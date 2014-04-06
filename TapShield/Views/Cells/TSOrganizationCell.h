//
//  TSOrganizationCell.h
//  TapShield
//
//  Created by Adam Share on 2/20/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseTableViewCell.h"

@interface TSOrganizationCell : TSBaseTableViewCell

@property (nonatomic, strong) TSJavelinAPIAgency *agency;
@property (strong, nonatomic) TSBaseLabel *organizationLabel;
@property (strong, nonatomic) UIImageView *logoImageView;


@end
