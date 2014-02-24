//
//  TSUserProfileCell.h
//  TapShield
//
//  Created by Adam Share on 2/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSJavelinAPIClient.h"

@interface TSUserProfileCell : UITableViewCell

@property (nonatomic, strong) TSJavelinAPIUser *user;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *organizationLabel;
@property (nonatomic, strong) UILabel *disarmCodeLabel;


@end
