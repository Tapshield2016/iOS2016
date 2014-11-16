//
//  TSJavelinAPITheme.h
//  TapShield
//
//  Created by Adam Share on 11/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@interface TSJavelinAPITheme : TSJavelinAPIBaseModel


@property (strong, nonatomic) UIColor *primaryColor;
@property (strong, nonatomic) UIColor *secondaryColor;
@property (strong, nonatomic) UIColor *alternateColor;

@property (strong, nonatomic) NSString *smallLogoUrl;
@property (strong, nonatomic) NSString *navbarLogoUrl;
@property (strong, nonatomic) NSString *navbarLogoAlternateUrl;
@property (strong, nonatomic) NSString *mapOverlayLogoUrl;

@property (strong, nonatomic) UIImage *smallLogo;
@property (strong, nonatomic) UIImage *navbarLogo;
@property (strong, nonatomic) UIImage *navbarLogoAlternate;
@property (strong, nonatomic) UIImage *mapOverlayLogo;

@end
