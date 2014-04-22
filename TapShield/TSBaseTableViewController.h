//
//  TSBaseTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import "TSConstants.h"
#import "TSAppDelegate.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSColorPalette.h"
#import "UIImage+Color.h"
#import "UIView+FirstResponder.h"
#import "TSLocationController.h"
#import "TSTransitionDelegate.h"
#import "TSCircularButton.h"
#import "TSRalewayFont.h"
#import "TSBaseLabel.h"
#import "TSLogoImageView.h"
#import "TSUtilities.h"
#import "UIImage+Resize.h"
#import "TSBaseTextField.h"

@interface TSBaseTableViewController : UITableViewController

@property (strong, nonatomic) TSJavelinAPIUserProfile *userProfile;

@end
