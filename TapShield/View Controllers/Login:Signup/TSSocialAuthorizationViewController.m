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
#import "TSRegisterViewController.h"
#import "TSAnimatedView.h"

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
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] logoutSocial];
    
    [_signInGooglePlusButton clearButtonStyleAndCustomize];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.translucentBackground = YES;

    // Twitter setup
    _accountStore = [[ACAccountStore alloc] init];
    _apiManager = [[TWAPIManager alloc] init];

    // Facebook setup
    _facebookLoginView.readPermissions = @[@"basic_info", @"email", @"user_likes"];

    // Google+ setup
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kGooglePlusClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    //signIn.scopes = @[ @"profile" ];            // "profile" scope
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;

    // LinkedIn setup
    // https://github.com/jeyben/IOSLinkedInAPI
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.tapshield.com"
                                                                                    clientId:@"75cqjrach211kt"
                                                                                clientSecret:@"wAdZqm3bZJkKgq0l"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_fullprofile", @"r_emailaddress", @"r_contactinfo"]];
    _linkedInClient = [LIALinkedInHttpClient clientForApplication:application presentingViewController:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_hasAnimated) {
        if (_logIn) {
            [self.view sendSubviewToBack:_signUpButton];
            [self animateLoginButtons];
        }
        else {
            [self.view sendSubviewToBack:_loginButton];
            [self animateSignupButtons];
        }
    }
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_bg"]];
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
}

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

- (void)animateButtons:(NSArray *)buttons aroundFrame:(UIView *)view startingFromAngle:(float)startAngle firstEndingAngle:(float)endAngle separatedByAngle:(float)increment {
    
    _hasAnimated = YES;
    
    for (TSAnimatedView *circleButtons in buttons) {
        if (endAngle >= 2 * M_PI) {
            endAngle -= 2 * M_PI;
        }
        
        [((TSAnimatedView *)circleButtons) addCircularAnimationWithCircleFrame:view.frame arcCenter:view.center startAngle:startAngle endAngle:endAngle duration:0.3f];
        
        endAngle += increment;
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
    
    UIViewController *viewController;
    
    if (_logIn) {
        viewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSLoginViewController class])];
    }
    else {
        viewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSRegisterViewController class])];
    }
    
    _transitionDelegate = [[TSTransitionDelegate alloc] init];
    
    [self pushViewControllerWithClass:[TSLoginViewController class] transitionDelegate:_transitionDelegate navigationDelegate:_transitionDelegate animated:YES];
}


#pragma mark - LinkedIn methods

- (IBAction)didTapConnectWithLinkedIn:(id)sender {
    [_linkedInClient getAuthorizationCode:^(NSString *code) {
        [_linkedInClient getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [[[TSJavelinAPIClient sharedClient] authenticationManager] createLinkedInUser:accessToken];
            [self requestMeWithToken:accessToken];
        }                   failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                      cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                     failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
}


- (void)requestMeWithToken:(NSString *)accessToken {
    [_linkedInClient GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

#pragma mark - Google+ Delegate methods

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@", error, auth);
    [[[TSJavelinAPIClient sharedClient] authenticationManager] createGoogleUser:auth.parameters[@"access_token"] refreshToken:auth.parameters[@"refresh_token"]];
}

#pragma mark - FBLoginViewDelegate methods

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSLog(@"Something went wrong: %@", error);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    NSLog(@"%@", user);
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView; {
    NSLog(@"User is logged in. Access token is %@", [[FBSession.activeSession accessTokenData] accessToken]);
    [[[TSJavelinAPIClient sharedClient] authenticationManager] createFacebookUser:[[FBSession.activeSession accessTokenData] accessToken]];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"User is logged out...");
    [[[TSJavelinAPIClient sharedClient] authenticationManager] logoutSocial];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [_apiManager performReverseAuthForAccount:_accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData) {
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSLog(@"Reverse Auth process returned: %@", responseStr);
                
                NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                NSString *lined = [parts componentsJoinedByString:@"\n"];

                // Turn response into dictionary for ease of use...
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                for (NSString *param in [responseStr componentsSeparatedByString:@"&"]) {
                    NSArray *elements = [param componentsSeparatedByString:@"="];
                    if([elements count] < 2) continue;
                    [params setObject:[elements objectAtIndex:1] forKey:[elements objectAtIndex:0]];
                }

                [[[TSJavelinAPIClient sharedClient] authenticationManager] createTwitterUser:params[@"oauth_token"] secretToken:params[@"oauth_token_secret"]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:lined delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
            else {
                NSLog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
            }
        }];
    }
}

#pragma mark - Twitter-related methods
/**
 *  Checks for the current Twitter configuration on the device / simulator.
 *
 *  First, we check to make sure that we've got keys to work with inside Info.plist (see README)
 *
 *  Then we check to see if the device has accounts available via +[TWAPIManager isLocalTwitterAccountAvailable].
 *
 *  Next, we ask the user for permission to access his/her accounts.
 *
 *  Upon completion, the button to continue will be displayed, or the user will be presented with a status message.
 */

- (IBAction)refreshTwitterAccounts:(id)sender
{
    NSLog(@"Refreshing Twitter Accounts \n");
    
    if (![TWAPIManager hasAppKeys]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_KEYS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        [alert show];
    }
    else if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_ACCOUNTS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self _obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self performReverseAuth:nil];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_PERM_ACCESS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
                    [alert show];
                    NSLog(@"You were not granted access to the Twitter accounts.");
                }
            });
        }];
    }
}


- (void)_obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    [_accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}

/**
 *  Handles the button press that initiates the token exchange.
 *
 *  We check the current configuration inside -[UIViewController viewDidAppear].
 */
- (void)performReverseAuth:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (ACAccount *acct in _accounts) {
        [sheet addButtonWithTitle:acct.username];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:self.view];
}



#pragma mark - Animations




@end
