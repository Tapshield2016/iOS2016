//
//  TSViewController.h
//  SocialAuthTest
//
//  Created by Ben Boyd on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>

@class GPPSignInButton;

@interface TSSocialAuthorizationViewController : TSBaseViewController <FBLoginViewDelegate, UIActionSheetDelegate, GPPSignInDelegate>

@property (nonatomic, weak) IBOutlet FBLoginView *fbLoginView;
@property (nonatomic, weak) IBOutlet GPPSignInButton *signInButton;

- (IBAction)refreshTwitterAccounts:(id)sender;
- (IBAction)didTapConnectWithLinkedIn:(id)sender;

@end
