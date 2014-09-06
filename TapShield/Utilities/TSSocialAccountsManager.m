//
//  TSSocialAccounts.m
//  TapShield
//
//  Created by Adam Share on 3/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//
#import "TSSocialAccountsManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FacebookSDK/FBRequestConnection+Internal.h>
#import "TSUtilities.h"
#import <FBShimmeringView.h>
#import "TSPopUpWindow.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import <FacebookSDK/FBSession+Internal.h>
#import <Social/Social.h>
#import "TSApplication.h"
#import "TSWebViewController.h"

#define ERROR_TITLE_MSG @"Sorry"
#define ERROR_NO_ACCOUNTS @"No Twitter account could be found. Please add a Twitter account in the Settings app"
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK @"OK"

#ifdef APP_STORE
static NSString * const kGooglePlusClientId = @"597251186165-6elcq16b3mb3tqvj1ctk33rg17ft5prs.apps.googleusercontent.com";
#else
static NSString * const kGooglePlusClientId = @"597251186165-oijnav4c8e4r2v5i66ggg9kiob9prng7.apps.googleusercontent.com";
#endif

static NSString * const kLinkedInClientId = @"75cqjrach211kt";
static NSString * const kLinkedInSecretKey = @"wAdZqm3bZJkKgq0l";

typedef enum TSSocialService : NSUInteger {
    facebook,
    twitter,
    google,
    linkedIn,
}TSSocialService;

@interface TSSocialAccountsManager ()

@property (weak, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) UIView *currentView;
@property (strong, nonatomic) UIAlertView *passcodeAlertView;
@property (strong, nonatomic) TSPopUpWindow *loadingWindow;
@property (strong, nonatomic) TSWebViewController *webViewController;

@end


@implementation TSSocialAccountsManager


static TSSocialAccountsManager *_sharedSocialAccountsManagerInstance = nil;
static dispatch_once_t predicate;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginGooglePlusWebView:)
                                                     name:ApplicationOpenGoogleAuthNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(signUpDidFailToLogin:)
                                                     name:kTSJavelinAPIAuthenticationManagerDidFailToCreateConnectionToAuthURL
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(signUpDidFailToLogin:)
                                                     name:kTSJavelinAPIAuthenticationManagerDidFailToLogin
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(signUpDidLoginSuccessfully:)
                                                     name:kTSJavelinAPIAuthenticationManagerDidLoginSuccessfully
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(signUpDidFailToLogin:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)signUpDidLoginSuccessfully:(NSNotification *)note {
    
    [self finishedLoading];
}

- (void)signUpDidFailToLogin:(NSNotification *)note {
    
    [self finishedLoading];
}

+ (instancetype)sharedManager {
    
    if (_sharedSocialAccountsManagerInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedSocialAccountsManagerInstance = [[self alloc] init];
        });
    }
    
    return _sharedSocialAccountsManagerInstance;
}

- (void)logInWithFacebook {
    
    [self loading:facebook];
    [self loginFacebook];
}

- (void)logInWithGooglePlus:(id)currentViewController {
    _currentViewController = currentViewController;
    [self loading:google];
    [self initGooglePlus];
    [[GPPSignIn sharedInstance] authenticate];
}

- (BOOL)silentLogInWithGooglePlus {
    
    [self initGooglePlus];
    return [[GPPSignIn sharedInstance] trySilentAuthentication];
}

- (void)logInWithTwitter:(UIView *)currentView {

    _currentView = currentView;
    [self initTwitter];
    [self loginTwitter];
}

- (void)logInWithLinkedIn:(id)currentViewController {
    
    [self initLinkedIn:currentViewController];
    [self loginLinkedIn];
}

- (void)initLinkedIn:(id)currentViewController {
    
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"https://tapshield.com/"
                                                                                    clientId:@"75cqjrach211kt"
                                                                                clientSecret:@"wAdZqm3bZJkKgq0l"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_fullprofile", @"r_emailaddress", @"r_contactinfo"]];
    self.linkedInClient = [LIALinkedInHttpClient clientForApplication:application presentingViewController:currentViewController];
}

- (void)initGooglePlus {
    
    // Google+ setup
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = kGooglePlusClientId;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.delegate = self;
}

- (void)initTwitter {
    
    // Twitter setup
    self.accountStore = [[ACAccountStore alloc] init];
    self.apiManager = [[TWAPIManager alloc] init];
}


- (void)logoutAllUserTypesCompletion:(LoggedOutBlock)completion {
    
    [self logoutFacebook];
    [self logoutGooglePlus];
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] logoutUser:^(BOOL success) {
        if (success) {
            [[[TSJavelinAPIClient sharedClient] authenticationManager] logoutSocial];
            
        }
        if (completion) {
            completion(success);
        }
    }];
}

- (void)logoutGooglePlus {
    
    [[GPPSignIn sharedInstance] signOut];
}


#pragma mark - LinkedIn methods

- (void)loginLinkedIn {
    
    [_linkedInClient getAuthorizationCode:^(NSString *code) {
        [self loading:linkedIn];
        [_linkedInClient getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [self loading:linkedIn];
            [[[TSJavelinAPIClient sharedClient] authenticationManager] createLinkedInUser:accessToken completion:^(BOOL finished) {
                if (finished) {
                    [self requestMeWithToken:accessToken];
                }
            }];
            
        }                   failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
            [self finishedLoading];
        }];
    }                      cancel:^{
        NSLog(@"Authorization was cancelled by user");
        [self finishedLoading];
    }                     failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
        [self finishedLoading];
    }];
}


- (void)requestMeWithToken:(NSString *)accessToken {
    [_linkedInClient GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(date-of-birth,picture-url,phone-numbers,main-address)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
        [[TSJavelinAPIClient loggedInUser] updateUserProfileFromLinkedIn:result];
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

#pragma mark - Google+ Delegate methods

- (void)loginGooglePlusWebView:(NSNotification *)notification {
    
    [self finishedLoading];
    if ([notification.object isKindOfClass:[NSURL class]]) {
        [TSWebViewController controller:_currentViewController presentWebViewControllerWithURL:notification.object delegate:self];
    }
}

- (void)googlePlusLoginCancelled {
    
    [self finishedLoading];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[[request URL] absoluteString] hasPrefix:[[NSString stringWithFormat:@"%@:/oauth2callback", [[NSBundle mainBundle] bundleIdentifier]] lowercaseString]]) {
        [GPPURLHandler handleURL:request.URL sourceApplication:@"com.google.chrome.ios" annotation:nil];
        [_webViewController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@", error, auth);
    
    [self loading:google];
    [[[TSJavelinAPIClient sharedClient] authenticationManager] createGoogleUser:auth.parameters[@"access_token"] refreshToken:auth.parameters[@"refresh_token"] completion:^(BOOL finished) {
        
        if (finished) {
            GTLPlusPerson *user = [GPPSignIn sharedInstance].googlePlusUser;
            [[TSJavelinAPIClient loggedInUser] updateUserProfileFromGoogle:user];
        }
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        [self loading:twitter];
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
                
                [self loading:twitter];
                [[[TSJavelinAPIClient sharedClient] authenticationManager] createTwitterUser:params[@"oauth_token"] secretToken:params[@"oauth_token_secret"] completion:^(BOOL finished) {
                    if (finished) {
                        [self twitterRequest];
                    }
                }];
                
                NSLog(@"%@", lined);
            }
            else {
                NSLog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
                [self finishedLoading];
            }
        }];
    }
    else {
        [self finishedLoading];
    }
}

- (void)twitterRequest {
    
    //  Step 1:  Obtain access to the user's Twitter accounts
    ACAccountType *twitterAccountType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:
     ACAccountTypeIdentifierTwitter];
    
    //  Step 2:  Create a request
    NSArray *twitterAccounts =
    [self.accountStore accountsWithAccountType:twitterAccountType];
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                  @"/1.1/users/show.json"];
    NSDictionary *params = @{@"screen_name" : [TSJavelinAPIClient loggedInUser].username};
    SLRequest *request =
    [SLRequest requestForServiceType:SLServiceTypeTwitter
                       requestMethod:SLRequestMethodGET
                                 URL:url
                          parameters:params];
    
    //  Attach an account to the request
    [request setAccount:[twitterAccounts lastObject]];
    
    //  Step 3:  Execute the request
    [request performRequestWithHandler:
     ^(NSData *responseData,
       NSHTTPURLResponse *urlResponse,
       NSError *error) {
         
         if (responseData) {
             if (urlResponse.statusCode >= 200 &&
                 urlResponse.statusCode < 300) {
                 
                 NSError *jsonError;
                 NSDictionary *timelineData =
                 [NSJSONSerialization
                  JSONObjectWithData:responseData
                  options:NSJSONReadingAllowFragments error:&jsonError];
                 if (timelineData) {
                     NSLog(@"Timeline Response: %@\n", timelineData);
                     [[TSJavelinAPIClient loggedInUser] updateUserProfileFromTwitter:timelineData];
                 }
                 else {
                     // Our JSON deserialization went awry
                     NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                 }
             }
             else {
                 // The server did not respond ... were we rate-limited?
                 NSLog(@"The response status code is %d",
                       urlResponse.statusCode);
             }
         }
     }];
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

- (void)loginTwitter
{
    if (![TWAPIManager hasAppKeys]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_KEYS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        [alert show];
    }
    else if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_ACCOUNTS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self loading:twitter];
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
                [self finishedLoading];
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
    [self finishedLoading];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (ACAccount *acct in _accounts) {
        [sheet addButtonWithTitle:acct.username];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:_currentView];
}


#pragma mark - Facebook

- (void)loginFacebook {
    
    
    
    //    // Open session with public_profile (required) and user_birthday read permissions
    //    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
    //                                       allowLoginUI:YES
    //                                  completionHandler:
    
    
    [FBSession openActiveSessionWithPermissions:@[@"public_profile", @"email"]
                                  loginBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                                         isRead:YES
                                defaultAudience:FBSessionDefaultAudienceNone
                              completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
         __block NSString *alertText;
         __block NSString *alertTitle;
         if (!error){
             [self facebookLoggedIn];
             
         } else {
             // There was an error, handle it
             [self finishedLoading];
             if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
                 // Error requires people using an app to make an action outside of the app to recover
                 // The SDK will provide an error message that we have to show the user
                 alertTitle = @"Something went wrong";
                 alertText = [FBErrorUtility userMessageForError:error];
                 [[[UIAlertView alloc] initWithTitle:alertTitle
                                             message:alertText
                                            delegate:self
                                   cancelButtonTitle:@"OK!"
                                   otherButtonTitles:nil] show];
                 
                 
             } else {
                 // If the user cancelled login
                 if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                     alertTitle = @"Facebook login cancelled";
                     alertText = @"Please try again, or select another method";
                     [[[UIAlertView alloc] initWithTitle:alertTitle
                                                 message:alertText
                                                delegate:self
                                       cancelButtonTitle:@"OK!"
                                       otherButtonTitles:nil] show];
                 } else {
                     // For simplicity, in this sample, for all other errors we show a generic message
                     // You can read more about how to handle other errors in our Handling errors guide
                     // https://developers.facebook.com/docs/ios/errors/
                     NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
                                                        objectForKey:@"body"]
                                                       objectForKey:@"error"];
                     alertTitle = @"Something went wrong";
                     alertText = [NSString stringWithFormat:@"Please retry.\nIf the problem persists contact us and mention this error code: %@",
                                  [errorInformation objectForKey:@"message"]];
                     [[[UIAlertView alloc] initWithTitle:alertTitle
                                                 message:alertText
                                                delegate:self
                                       cancelButtonTitle:@"OK!"
                                       otherButtonTitles:nil] show];
                 }
             }
         }
     }];
}

- (void)facebookLoggedIn {
    
    FBSession *session = [FBSession activeSession];
    // If the session was opened successfully
    if (session.state == FBSessionStateOpen){
        // Your code here
        
        [self loading:facebook];
        [[[TSJavelinAPIClient sharedClient] authenticationManager] createFacebookUser:[[FBSession.activeSession accessTokenData] accessToken] completion:^(BOOL finished) {
            
            if (!finished) {
                return ;
            }
            
            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                if (error) {
                    NSLog(@"error:%@",error);
                } else {
                    [[TSJavelinAPIClient loggedInUser] updateUserProfileFromFacebook:user];
                }
            }];
        }];
    }
}

- (void)logoutFacebook {
    
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
    }
}


#pragma mark - Loading Window

- (void)loading:(TSSocialService)service {
    
    UIImage *logo;
    
    switch (service) {
        case facebook:
            logo = [UIImage imageNamed:@"facebook_icon"];
            break;
            
        case twitter:
            logo = [UIImage imageNamed:@"twitter_icon"];
            break;
            
        case google:
            logo = [UIImage imageNamed:@"google_icon"];
            break;
            
        case linkedIn:
            logo = [UIImage imageNamed:@"linkedin_icon"];
            break;
            
        default:
            break;
    }
    
    if (_loadingWindow) {
        return;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:logo];
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:imageView.bounds];
    shimmeringView.contentView = imageView;
    shimmeringView.shimmering = YES;
    shimmeringView.shimmeringSpeed = 150;
    
    _loadingWindow = [[TSPopUpWindow alloc] initWithView:imageView];
    [_loadingWindow show];
    _loadingWindow.windowLevel = UIWindowLevelNormal;
}

- (void)finishedLoading {
    
    [_loadingWindow dismiss:^(BOOL finished) {
        _loadingWindow = nil;
    }];
}

@end
