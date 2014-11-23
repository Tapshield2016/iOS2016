//
//  TSBaseViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"
#import "TSGeofence.h"
#import <KVOController/FBKVOController.h>
#import "TSAlertManager.h"

@interface TSBaseViewController ()

@property (strong, nonatomic) FBKVOController *kvoController;

@end

@implementation TSBaseViewController

- (UIViewController *)presentViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate animated:(BOOL)animated {
    
    [self viewWillDisappear:animated];
    
    UIViewController *viewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([viewControllerClass class])];
    
    UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationViewController setNavigationBarHidden:animated];
    navigationViewController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    if (delegate) {
        [navigationViewController setTransitioningDelegate:delegate];
        navigationViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    [self presentViewController:navigationViewController animated:animated completion:nil];
    
    return viewController;
}


- (void)presentNavigationController:(UINavigationController *)navigationController transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate animated:(BOOL)animated {
    
    navigationController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    
    if (delegate) {
        [navigationController setTransitioningDelegate:delegate];
        navigationController.modalPresentationStyle = UIModalPresentationCustom;
    }
    [self presentViewController:navigationController animated:animated completion:nil];
}


- (UIViewController *)pushViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)transitionDelegate navigationDelegate:(id <UINavigationControllerDelegate>)navigationDelegate animated:(BOOL)animated {
    
    UIViewController *viewController = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([viewControllerClass class])];
    
    if (transitionDelegate && navigationDelegate) {
        viewController.transitioningDelegate = transitionDelegate;
        self.navigationController.delegate = navigationDelegate;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.screenName = self.title;
}

- (void)setTranslucentBackground:(BOOL)translucentBackground {
    
    _translucentBackground = translucentBackground;
    
    if (translucentBackground) {
        _toolbar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _toolbar.frame = self.view.bounds;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_toolbar atIndex:0];
    }
}

#pragma mark - Agency UI Updates

- (void)initTitleLogoView {
    
    if (!_logoTitleView) {
        _logoTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, [UIScreen mainScreen].bounds.size.width/2, 34)];
        _logoTitleView.backgroundColor = [UIColor clearColor];
        _navbarLogoImageView = [[TSLogoImageView alloc] initWithFrame:_logoTitleView.bounds];
        [_logoTitleView addSubview:_navbarLogoImageView];
    }
    
    self.navigationItem.titleView = _logoTitleView;
}

- (void)setShowAlternateLogoInNavBar:(BOOL)showAlternateLogoInNavBar {
    
    _showAlternateLogoInNavBar = showAlternateLogoInNavBar;
    
    if (showAlternateLogoInNavBar) {
        
        [self initTitleLogoView];
        
        [self updateLogoImages];
    }
    else {
        [_logoTitleView removeFromSuperview];
    }
    
    [TSGeofence registerForAgencyProximityUpdates:self action:@selector(updateLogoImages)];
}

- (void)showAlternate {
    
    if (_showAlternateLogoInNavBar) {
        UIImage *image = [TSLocationController sharedLocationController].geofence.currentAgency.theme.navbarLogoAlternate;
        NSString *defaultImage = TSLogoImageViewBigTapShieldLogo;
        
        if (!image) {
            if (![TSLocationController sharedLocationController].geofence.currentAgency) {
                
                if ([[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.dispatcherSecondaryPhoneNumber isEqualToString:kEmergencyNumber] ||
                    ![[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency) {
                    defaultImage = TSLogoImageView911;
                }
                
                if ([TSAlertManager sharedManager].type == kAlertTypeAlertCall) {
                    image = [TSJavelinAPIClient loggedInUser].agency.theme.navbarLogoAlternate;
                }
            }
        }
        
        [_navbarLogoImageView setImage:image defaultImageName:defaultImage];
    }
}

- (void)setShowLogoInNavBar:(BOOL)showLogoInNavBar {
    
    _showLogoInNavBar = showLogoInNavBar;
    
    if (_showLogoInNavBar) {
        [self initTitleLogoView];
        
        [self updateLogoImages];
    }
    else {
        [_logoTitleView removeFromSuperview];
    }
    
//    [TSGeofence registerForAgencyProximityUpdates:self action:@selector(updateLogoImages)];
}

- (void)showNavBarLogo {
    if (_showLogoInNavBar) {
        UIImage *image = [TSLocationController sharedLocationController].geofence.currentAgency.theme.navbarLogo;
        [_navbarLogoImageView setImage:image defaultImageName:TSLogoImageViewSmallTapShieldLogo];
    }
}

- (void)updateLogoImages {
    
    if (!_kvoController) {
        _kvoController = [FBKVOController controllerWithObserver:self];
    }
    
    if (_showAlternateLogoInNavBar) {
        
        if (![TSLocationController sharedLocationController].geofence.currentAgency || ![TSLocationController sharedLocationController].geofence.currentAgency.theme) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self showAlternate];
            }];
        }
        
        [_kvoController observe:[TSLocationController sharedLocationController].geofence.currentAgency.theme keyPath:@"navbarLogoAlternate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial block:^(TSBaseViewController *weakSelf, TSJavelinAPITheme *theme, NSDictionary *change) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakSelf showAlternate];
            }];
        }];
    }
    else if (_showLogoInNavBar) {
        
        if (![TSLocationController sharedLocationController].geofence.currentAgency  || ![TSLocationController sharedLocationController].geofence.currentAgency.theme) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self showNavBarLogo];
            }];
        }
        
        [_kvoController observe:[TSLocationController sharedLocationController].geofence.currentAgency.theme keyPath:@"navbarLogo" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial block:^(TSBaseViewController *weakSelf, TSJavelinAPITheme *theme, NSDictionary *change) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf showNavBarLogo];
            }];
        }];
    }
    
    
//    UIImage *image;
//    if (_showAlternateLogoInNavBar) {
//        image = [TSLocationController sharedLocationController].geofence.currentAgency.theme.navbarLogoAlternate;
//        [_navbarLogoImageView setImage:image defaultImageName:TSLogoImageViewBigTapShieldLogo];
//    }
//    else if (_showLogoInNavBar) {
//        image = [TSLocationController sharedLocationController].geofence.currentAgency.theme.navbarLogo;
//        [_navbarLogoImageView setImage:image defaultImageName:TSLogoImageViewSmallTapShieldLogo];
//    }
}

#pragma mark - Nav Bars

- (void)whiteNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [UINavigationBar appearance].tintColor = [TSColorPalette tapshieldBlue];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.3] , NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
}

- (void)blackNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    [UINavigationBar appearance].tintColor = [TSColorPalette whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette whiteColor], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette whiteColor], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.5] , NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
}

#pragma mark - Table View Customization

- (void)customizeTableView:(UITableView *)tableView {
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Search Bar Customization

- (void)customizeSearchBarAppearance:(UISearchBar *)searchBar {
    
    searchBar.barStyle = UISearchBarStyleMinimal;
    
    for (UIView *subview in searchBar.subviews) {
        
        if (subview.subviews) {
            for (UIView *view in subview.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                    [view removeFromSuperview];
                    break;
                }
            }
        }
        
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }
    
    UITextField *textField = [((UITextField *)[searchBar.subviews firstObject]).subviews lastObject];
//    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].backgroundColor = [TSColorPalette searchFieldBackgroundColor];
//    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].font = [TSFont fontWithName:kFontWeightLight size:16.0];
//    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].textColor = [UIColor whiteColor];
//    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].tintColor = [UIColor whiteColor];
//    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].borderStyle = UITextBorderStyleNone;
//    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    textField.backgroundColor = [TSColorPalette searchFieldBackgroundColor];
    textField.font = [TSFont fontWithName:kFontWeightLight size:16.0];
    textField.textColor = [UIColor whiteColor];
    textField.tintColor = [UIColor whiteColor];
    textField.borderStyle = UITextBorderStyleNone;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    textField.layer.cornerRadius = 3.0f;
    textField.layer.masksToBounds = YES;
    
    searchBar.tintColor = [TSColorPalette tapshieldBlue];
//    searchBar.barTintColor = [TSColorPalette listBackgroundColor];
    
    UIImage *leftViewImage = [UIImage imageNamed:@"SearchBar"];
    [searchBar setImage:[leftViewImage fillImageWithColor:[UIColor whiteColor]] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    UIImage *clearImage = [UIImage imageNamed:@"switch_off"];
    clearImage = [clearImage resizeToSize:CGSizeMake(clearImage.size.width/2, clearImage.size.height/2)];
    [searchBar setImage:clearImage forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    
    clearImage = [clearImage imageWithAlpha:0.5];
    [searchBar setImage:clearImage forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
}


#pragma mark - MSDynamicDrawer Settings

- (void)drawerCanDragForMenu:(BOOL)enabled {
    [(TSAppDelegate *)[UIApplication sharedApplication].delegate drawerCanDragForMenu:enabled];
}


@end
