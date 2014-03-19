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
#import "TSFacebookLogin.h"
#import "TSGooglePlusButton.h"

@class GPPSignInButton;

@interface TSSocialAuthorizationViewController : TSBaseViewController <FBLoginViewDelegate, UIActionSheetDelegate, GPPSignInDelegate>

@property (weak, nonatomic) IBOutlet TSCircularButton *loginButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *signUpButton;

@property (nonatomic, weak) IBOutlet TSFacebookLogin *facebookLoginView;
@property (nonatomic, weak) IBOutlet TSGooglePlusButton *signInGooglePlusButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *twitterButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *linkedInButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *emailButton;

@property (nonatomic) BOOL logIn;

- (IBAction)dismissViewController:(id)sender;

- (IBAction)refreshTwitterAccounts:(id)sender;
- (IBAction)didTapConnectWithLinkedIn:(id)sender;
- (IBAction)emailLoginSignup:(id)sender;



@end
