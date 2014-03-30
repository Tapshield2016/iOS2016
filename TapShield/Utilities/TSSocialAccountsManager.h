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
#import <FacebookSDK/FacebookSDK.h>
#import "TSFacebookLogin.h"

// Twitter-related imports
#import <Accounts/Accounts.h>
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"

// Google+
#import "TSGooglePlusButton.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

// LinkedIn
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

@class GPPSignInButton;

@interface TSSocialAccountsManager : NSObject <FBLoginViewDelegate, UIActionSheetDelegate, GPPSignInDelegate, TSJavelinAuthenticationManagerDelegate>

typedef void (^LoggedOutBlock)(BOOL loggedOut);

@property (nonatomic, copy) LoggedOutBlock loggedOutBlock;
@property (nonatomic, strong) FBLoginView *facebookLoginView;
@property (nonatomic, strong) GPPSignInButton *signInGooglePlusButton;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) LIALinkedInHttpClient *linkedInClient;

@property (nonatomic) BOOL facebookLoggedIn;

+ (instancetype)sharedSocialAccountsManager;

- (void)initializeFacebookView;
- (void)deallocFacebookView;
- (void)logoutAllUserTypesCompletion:(LoggedOutBlock)completion;
- (void)addSocialViewsTo:(UIView *)view ;

@end
