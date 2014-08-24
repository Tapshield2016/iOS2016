//
//  TSViewController.m
//  SocialAuthTest
//
//  Created by Ben Boyd on 3/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSocialAuthorizationViewController.h"
#import "TSJavelinAPIClient.h"
#import "TSLoginViewController.h"
#import "TSAskOrganizationViewController.h"
#import "TSAnimatedView.h"
#import "TSSocialAccountsManager.h"
#import "TSUserSessionManager.h"
#import "TSAgreementViewController.h"
#import "TSPopUpWindow.h"

// Twitter-related imports
#import <Accounts/Accounts.h>
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"

// Google+
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

// LinkedIn
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

#define ERROR_TITLE_MSG @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings.app to use this demo."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK @"OK"

#define SignUpStartAngle (float)2*M_PI
#define LogInStartAngle (float)M_PI

static NSString * const kGooglePlusClientId = @"61858600218-1jnu8vt0chag0dphiv0oj69ab32ces5n.apps.googleusercontent.com";

@interface TSSocialAuthorizationViewController ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) LIALinkedInHttpClient *linkedInClient;

@property (nonatomic, strong) NSArray *buttonArray;

@end

@implementation TSSocialAuthorizationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _buttonArray = @[_facebookView, _twitterView, _googleView, _linkedinView, _emailView];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.translucentBackground = YES;
    self.toolbar.alpha = 0.99;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissViewController:)];
    [self.toolbar addGestureRecognizer:tap];
    
    if (_logIn) {
        [self.view sendSubviewToBack:_signUpButton];
    }
    else {
        [self.view sendSubviewToBack:_loginButton];
    }
    
    [self.view sendSubviewToBack:_logoImageView];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_bg"]];
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [[TSJavelinAPIClient sharedClient] authenticationManager].delegate = self;
    
    if (!_hasAnimated) {
        if (_logIn) {
            [self animateLoginButtons];
        }
        else {
            [self animateSignupButtons];
        }
    }
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if (_hasAnimated) {
        [self reframeButtons];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissViewController:(id)sender {
    
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Email methods 

- (IBAction)emailLoginSignup:(id)sender {
    
    Class class;
    
    if (_logIn) {
        class = [TSLoginViewController class];
        
        _transitionDelegate = [[TSTransitionDelegate alloc] init];
        
        [self pushViewControllerWithClass:class transitionDelegate:_transitionDelegate navigationDelegate:_transitionDelegate animated:YES];
    }
    else {
        class = [TSRegisterViewController class];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self presentViewControllerWithClass:class transitionDelegate:nil animated:YES];
    }
}

- (IBAction)logInWithFacebook:(id)sender {
    
    [[TSSocialAccountsManager sharedManager] logInWithFacebook];
}

- (IBAction)logInWithGooglePlus:(id)sender {
    
    [[TSSocialAccountsManager sharedManager] logInWithGooglePlus];
}

- (IBAction)showEULA:(id)sender {
    
    [self pushViewControllerWithClass:[TSAgreementViewController class] transitionDelegate:nil navigationDelegate:nil animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - LinkedIn methods

- (IBAction)didTapConnectWithLinkedIn:(id)sender {
    
    [[TSSocialAccountsManager sharedManager] logInWithLinkedIn:self];
}


#pragma mark - Twitter

- (IBAction)refreshTwitterAccounts:(id)sender {
    
    [[TSSocialAccountsManager sharedManager] logInWithTwitter:self.view];
}


#pragma mark - Authentication Manager Delegate 

- (void)loginSuccessful:(TSJavelinAPIAuthenticationResult *)result {
    
    [[TSJavelinAPIClient sharedClient] authenticationManager].delegate = nil;
    
    [[TSUserSessionManager sharedManager] dismissWindow:^(BOOL finished) {
        [[TSUserSessionManager sharedManager] userStatusCheck];
    }];
}

- (void)loginFailed:(TSJavelinAPIAuthenticationResult *)result {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] logoutSocial];
}


#pragma mark - Animations

- (void)animateLoginButtons {
    
    float endAngle = 2 * M_PI - M_PI_2 - 0.2f;
    float increment = M_PI/4.3;
    
    [self animateButtons:_buttonArray aroundFrame:_loginButton startingFromAngle:M_PI firstEndingAngle:endAngle separatedByAngle:increment];
}

- (void)animateSignupButtons {
    
    float endAngle = 2 * M_PI - M_PI_2 + 0.2f;
    float increment = -M_PI/4.3;
    
    [self animateButtons:_buttonArray aroundFrame:_signUpButton startingFromAngle:2*M_PI firstEndingAngle:endAngle separatedByAngle:increment];
}

- (void)animateButtons:(NSArray *)buttons aroundFrame:(UIView *)view startingFromAngle:(float)startAngle firstEndingAngle:(float)endAngle separatedByAngle:(float)angleIncrement {
    
    _hasAnimated = YES;
    float delayIncrement = 0.05f;
    float delay = delayIncrement * buttons.count;
    float duration = 0.1f;
    
    for (TSAnimatedView *circleButtons in buttons) {
        if (endAngle >= 2 * M_PI) {
            endAngle -= 2 * M_PI;
        }
        
        [((TSAnimatedView *)circleButtons) addCircularAnimationWithCircleFrame:view.frame arcCenter:view.center startAngle:startAngle endAngle:endAngle duration:duration delay:delay];
        
        delay -= delayIncrement;
        duration += delayIncrement;
        
        endAngle += angleIncrement;
    }
}

- (void)reframeButtons {
    
    for (TSAnimatedView *circleButtons in _buttonArray) {
        [circleButtons resetToEndFrame];
    }
}



@end
