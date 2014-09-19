//
//  TSUserSessionManager.m
//  TapShield
//
//  Created by Adam Share on 8/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserSessionManager.h"
#import "TSLocationController.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSPhoneNumberViewController.h"
#import "TSAddSecondaryViewController.h"
#import "TSNavigationDelegate.h"
#import "TSOrganizationSearchViewController.h"
#import "NSDate+Utilities.h"
#import "TSIntroPageViewController.h"
#import "UIViewController+Storyboard.h"

static NSString * const TSUserSessionManagerDeclinedAgency = @"TSUserSessionManagerDeclinedAgency";
static NSString * const TSUserSessionManagerMultipleAgenciesTitle = @"There are %i organizations using TapShield nearby";
static NSString * const TSUserSessionManagerMultipleAgenciesMessage = @"Would you like to join one now?";
static NSString * const TSUserSessionManagerSingleAgencyTitle = @"%@ is nearby";
static NSString * const TSUserSessionManagerSingleMessage = @"Would you like to join this organization?";

@interface TSUserSessionManager ()

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TSNavigationDelegate *navDelegate;
@property (strong, nonatomic) TSJavelinAPIAgency *agencyChosen;
@property (nonatomic, strong) UIAlertView *passcodeAlertView;
@property (nonatomic, strong) UIAlertView *multipleAgencyAlertView;
@property (nonatomic, strong) UIAlertView *singleAgencyAlertView;

@end

@implementation TSUserSessionManager

static TSUserSessionManager *_sharedManagerInstance = nil;
static dispatch_once_t predicate;


+ (instancetype)sharedManager {
    
    if (_sharedManagerInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedManagerInstance = [[self alloc] init];
        });
    }
    
    return _sharedManagerInstance;
}

- (void)userStatusCheck {
    
    if (![TSJavelinAPIClient loggedInUser]) {
        
        UIViewController *vc = [UIViewController instantiateFromStoryboard:[TSIntroPageViewController class]];
        [self showWindowWithRootViewController:vc];
        return;
    }
    
    if (![TSJavelinAPIClient loggedInUser].disarmCode ||
        [TSJavelinAPIClient loggedInUser].disarmCode.length != 4) {
        [self askForDisarmCode];
    }
    else if ([self shouldAskToJoinAgencies]) {
        [self checkForUserAgency];
    }
}

- (void)askForDisarmCode {
    
    _passcodeAlertView = [[UIAlertView alloc] initWithTitle:@"Enter a 4-digit passcode"
                                                    message:@"This code will be used to quickly verify your identity within the application"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    _passcodeAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [_passcodeAlertView textFieldAtIndex:0];
    [textField setPlaceholder:@"1234"];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setSecureTextEntry:YES];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [textField setDelegate:self];
    
    [_passcodeAlertView show];
}

- (void)checkForUserAgency {
    
    TSJavelinAPIUser *user = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser];
    BOOL userDeclined = [[NSUserDefaults standardUserDefaults] boolForKey:TSUserSessionManagerDeclinedAgency];
    
    if (!user || user.agency || userDeclined) {
        return;
    }
    
    [[TSLocationController sharedLocationController] startStandardLocationUpdates:^(CLLocation *location) {
        [[TSJavelinAPIClient sharedClient] getAgenciesNearby:location radius:10.0 completion:^(NSArray *agencies) {
            
            if (!agencies || !agencies.count) {
                return;
            }
            
            if ([self didJoinFromAgencies:agencies]) {
                return;
            }
            
            if ([self shouldAskToJoinAgencies]) {
                [self askToJoinAgencies:agencies];
            }
        }];
    }];
}

- (BOOL)didJoinFromSelectedAgency {
    
    if (!_agencyChosen) {
        return NO;
    }
    
    return [self didJoinFromAgency:_agencyChosen];
}

- (BOOL)didJoinFromAgency:(TSJavelinAPIAgency *)agency {
    
    TSJavelinAPIUser *user = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser];
    
    if (!user.isPhoneNumberVerified) {
        return NO;
    }

    if ([user isAvailableForDomain:agency.domain] || !agency.requireDomainEmails) {
        user.agency = agency;
        [self saveUser];
        return YES;
    }
    
    return NO;
}

- (BOOL)didJoinFromAgencies:(NSArray *)array {
    
    TSJavelinAPIUser *user = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser];
    for (TSJavelinAPIAgency *agency in array) {
        if ([user isAvailableForDomain:agency.domain] && user.isPhoneNumberVerified) {
            user.agency = agency;
            [self saveUser];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)shouldAskToJoinAgencies {
    
    return ![[NSUserDefaults standardUserDefaults] boolForKey:TSUserSessionManagerDeclinedAgency];
}

- (void)askToJoinAgencies:(NSArray *)agencies {
    
    if (agencies.count > 1) {
        _multipleAgencyAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:TSUserSessionManagerMultipleAgenciesTitle, agencies.count]
                                                              message:TSUserSessionManagerMultipleAgenciesMessage
                                                             delegate:self
                                                    cancelButtonTitle:@"Not now"
                                                    otherButtonTitles:@"Yes", nil];
        [_multipleAgencyAlertView show];
    }
    else if (agencies.count == 1) {
        
        _singleAgencyAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:TSUserSessionManagerSingleAgencyTitle, ((TSJavelinAPIAgency *)agencies[0]).name]
                                                            message:TSUserSessionManagerSingleMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"Not now"
                                                  otherButtonTitles:@"Yes", nil];
        _agencyChosen = agencies[0];
        [_singleAgencyAlertView show];
    }
}

- (void)showAgencyPicker {
    
    TSOrganizationSearchViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSOrganizationSearchViewController class])];
    [self showWindowWithRootViewController:vc animated:YES];
}

- (void)singleAgencyChoice:(TSJavelinAPIAgency *)agency {
    
    [TSUserSessionManager showAddSecondaryWithAgency:agency];
}

+ (BOOL)shouldShowPhoneVerification {
    
    if ([TSJavelinAPIClient loggedInUser].isPhoneNumberVerified) {
        return NO;
    }
    
    return YES;
}

+ (void)showPhoneVerification {
    
    UIViewController *rootViewController = [TSUserSessionManager sharedManager].window.rootViewController;
    TSPhoneNumberViewController *phoneViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSPhoneNumberViewController class])];
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)rootViewController pushViewController:phoneViewController animated:YES];
    }
    else {
        
        [[TSUserSessionManager sharedManager] showWindowWithRootViewController:phoneViewController animated:YES];
    }
}

+ (BOOL)phoneNumberWasVerified {
    
    if (![TSJavelinAPIClient loggedInUser].phoneNumberVerified) {
        return NO;
    }
    
    if ([TSUserSessionManager sharedManager].agencyChosen) {
        [[TSUserSessionManager sharedManager] didJoinFromAgency:[TSUserSessionManager sharedManager].agencyChosen];
    }
    
    return YES;
}


+ (void)showAddSecondaryWithAgency:(TSJavelinAPIAgency *)agency {
    
    if (!agency) {
        return;
    }
    
    [TSUserSessionManager sharedManager].agencyChosen = agency;
    
    if ([[TSUserSessionManager sharedManager] didJoinFromAgency:agency]) {
        [[TSUserSessionManager sharedManager] dismissWindow:nil];
    }
    else if (![[TSJavelinAPIClient loggedInUser] isAvailableForDomain:agency.domain] && agency.requireDomainEmails) {
        TSAddSecondaryViewController *addSecondaryVC = [TSUserSessionManager showAddSecondary];
        addSecondaryVC.agency = agency;
    }
    else if ([TSUserSessionManager shouldShowPhoneVerification]) {
        [TSUserSessionManager showPhoneVerification];
    }
}

+ (TSAddSecondaryViewController *)showAddSecondary {
    
    UIViewController *rootViewController = [TSUserSessionManager sharedManager].window.rootViewController;
    TSAddSecondaryViewController *addSecondaryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSAddSecondaryViewController class])];
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)rootViewController pushViewController:addSecondaryVC animated:YES];
    }
    else {
        
        [[TSUserSessionManager sharedManager] showWindowWithRootViewController:addSecondaryVC animated:YES];
    }
    
    return addSecondaryVC;
}

- (void)declineAddAgency {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TSUserSessionManagerDeclinedAgency];
    
    [self dismissWindow:nil];
}

#pragma mark UIWindow

- (void)showWindowWithRootViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (_window.isKeyWindow) {
        animated = NO;
    }
    
    [self showWindowWithRootViewController:viewController];
    
    if (animated) {
        CGRect frame = _window.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        _window.frame = frame;
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:300.0
              initialSpringVelocity:5.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _window.frame = [UIScreen mainScreen].bounds;
                         } completion:nil];
    }
}

- (void)showWindowWithRootViewController:(UIViewController *)viewController {
    
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = [UIColor clearColor];
    }
    
    if (viewController) {
        
        if (!_navDelegate) {
            _navDelegate = [[TSNavigationDelegate alloc] init];
        }
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        if (![viewController isKindOfClass:[TSIntroPageViewController class]]) {
            [_navDelegate customizeRegistrationNavigationController:navigationController];
        }
        
        _window.rootViewController = navigationController;
    }
    
    [_window makeKeyAndVisible];
}

- (void)dismissWindow:(void (^)(BOOL finished))completion  {
    
    UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIViewController *viewcontroller = [mainWindow.rootViewController.childViewControllers firstObject];
        
        [viewcontroller viewWillAppear:YES];
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:300.0
              initialSpringVelocity:5.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            _window.alpha = 0.0f;
        } completion:^(BOOL finished) {
            
            if (completion) {
                completion(finished);
            }
            
            [viewcontroller viewDidAppear:YES];
            [mainWindow makeKeyAndVisible];
            _window = nil;
        }];
    });
}
         

+ (UIViewController *)controllerFromClass:(Class)class {
    
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(class)];
}
         


#pragma mark - Alert View Delegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == _passcodeAlertView) {
        if (buttonIndex == 1) {
            [self saveUser];
            [self userStatusCheck];
        }
        UITextField *textField = [_passcodeAlertView textFieldAtIndex:0];
        [textField resignFirstResponder];
    }
    else if (alertView == _singleAgencyAlertView) {
        if (buttonIndex == 1) {
            [TSUserSessionManager showAddSecondaryWithAgency:_agencyChosen];
        }
        else {
            [self declineAddAgency];
        }
    }
    else if (alertView == _multipleAgencyAlertView) {
        
        if (buttonIndex == 1) {
            [self showAgencyPicker];
        }
        else {
            [self declineAddAgency];
        }
    }
    
}

- (void)saveUser {
    
    [[TSJavelinAPIAuthenticationManager sharedManager] archiveLoggedInUser];
    [[TSJavelinAPIAuthenticationManager sharedManager] updateLoggedInUser:nil];
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField.text length] + [string length] - range.length == 4) {
        textField.text = [textField.text stringByAppendingString:string];
        [self checkDisarmCode:textField];
        return NO;
    }
    else if ([textField.text length] + [string length] - range.length > 4) {
        [self checkDisarmCode:textField];
        return NO;
    }
    
    return YES;
}

- (void)checkDisarmCode:(UITextField *)textField {
    
    if ([TSUtilities removeNonNumericalCharacters:textField.text].length == 4) {
        
        [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode = textField.text;
        [_passcodeAlertView dismissWithClickedButtonIndex:1 animated:YES];
        
    }
    else {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
    }
}


@end
