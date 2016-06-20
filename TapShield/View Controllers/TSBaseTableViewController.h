//
//  TSBaseTableViewController.h
//  TapShield
//
//  Created by Adam Share on 4/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "TSConstants.h"
#import "TSAppDelegate.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSColorPalette.h"
#import "UIImage+Color.h"
#import "UIView+FirstResponder.h"
#import "TSLocationController.h"
#import "TSPushTransitionDelegate.h"
#import "TSCircularButton.h"
#import "TSFont.h"
#import "TSBaseLabel.h"
#import "TSLogoImageView.h"
#import "TSUtilities.h"
#import "UIImage+Resize.h"
#import "TSBaseTextField.h"

@interface TSBaseTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) TSJavelinAPIUserProfile *userProfile;

@end
