//
//  TSSocialAccounts.h
//  TapShield
//
//  Created by Adam Share on 3/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSJavelinAPIClient.h"

// Facebook
#import <FBSDKLoginKit/FBSDKLoginKit.h>

// Twitter-related imports
#import <Accounts/Accounts.h>
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"

// Google+
#import <GoogleSignIn/GoogleSignIn.h>

// LinkedIn
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

@class GPPSignInButton;

@interface TSSocialAccountsManager : NSObject <GIDSignInDelegate, GIDSignInUIDelegate, TSJavelinAuthenticationManagerDelegate, UITextFieldDelegate, UIWebViewDelegate>

typedef void (^LoggedOutBlock)(BOOL loggedOut);


@property (weak, nonatomic) UIViewController *currentViewController;
@property (nonatomic, copy) LoggedOutBlock loggedOutBlock;
@property (nonatomic, strong) GPPSignInButton *signInGooglePlusButton;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) LIALinkedInHttpClient *linkedInClient;

+ (instancetype)sharedManager;

- (void)logoutAllUserTypesCompletion:(LoggedOutBlock)completion;

- (void)logInWithFacebook;
- (void)logInWithGooglePlus:(id)currentViewController;
- (void)logInWithTwitter:(UIView *)currentView;
- (void)logInWithLinkedIn:(id)currentViewController;

- (BOOL)silentLogInWithGooglePlus;

- (void)facebookLoggedIn;

@end
