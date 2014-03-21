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
#import "TSAnimatedView.h"

@class GPPSignInButton;

@interface TSSocialAuthorizationViewController : TSBaseViewController <FBLoginViewDelegate, UIActionSheetDelegate, GPPSignInDelegate>

@property (weak, nonatomic) IBOutlet TSCircularButton *loginButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *signUpButton;

@property (nonatomic, weak) IBOutlet TSFacebookLogin *facebookLoginView;
@property (nonatomic, weak) IBOutlet TSGooglePlusButton *signInGooglePlusButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *twitterButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *linkedInButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *emailButton;

@property (weak, nonatomic) IBOutlet TSAnimatedView *facebookView;
@property (weak, nonatomic) IBOutlet TSAnimatedView *twitterView;
@property (weak, nonatomic) IBOutlet TSAnimatedView *googleView;
@property (weak, nonatomic) IBOutlet TSAnimatedView *linkedinView;
@property (weak, nonatomic) IBOutlet TSAnimatedView *emailView;

@property (strong, nonatomic) TSTransitionDelegate *transitionDelegate;


@property (nonatomic) BOOL logIn;
@property (nonatomic) BOOL hasAnimated;

- (IBAction)dismissViewController:(id)sender;

- (IBAction)refreshTwitterAccounts:(id)sender;
- (IBAction)didTapConnectWithLinkedIn:(id)sender;
- (IBAction)emailLoginSignup:(id)sender;



@end
