//
//  TSBaseViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"
#import "TSGeofence.h"

@interface TSBaseViewController ()

@end

@implementation TSBaseViewController

- (UIViewController *)presentViewControllerWithClass:(Class)viewControllerClass transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate animated:(BOOL)animated {
    
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
        _toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
        _toolbar.barStyle = UIBarStyleBlack;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_toolbar atIndex:0];
    }
}

#pragma mark - Agency UI Updates

- (void)setShowLargeLogo:(BOOL)showLargeLogo {
    _showLargeLogo = showLargeLogo;
    
    if (showLargeLogo) {
        
        UIImage *image = [TSLocationController sharedLocationController].geofence.currentAgency.largeLogo;
        
        NSString *defaultImage = TSLogoImageViewBigTapShieldLogo;
        if (!image) {
            if (![TSLocationController sharedLocationController].geofence.currentAgency) {
                if ([[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.dispatcherSecondaryPhoneNumber isEqualToString:kEmergencyNumber] ||
                    ![[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency) {
                    defaultImage = TSLogoImageView911;
                }
            }
        }
        
        _largeLogoImageView = [[TSLogoImageView alloc] initWithImage:image defaultImageName:defaultImage];
        _largeLogoImageView.preferredHeight = self.navigationController.navigationBar.frame.size.height - 10;
        
        self.navigationItem.titleView = _largeLogoImageView;
    }
    else {
        [_largeLogoImageView removeFromSuperview];
    }
    
    [TSGeofence registerForAgencyProximityUpdates:self action:@selector(updateLogoImages)];
}

- (void)setShowAlternateLogo:(BOOL)showAlternateLogo {
    
    _showAlternateLogo = showAlternateLogo;
    
    if (showAlternateLogo) {
        
        UIImage *image = [TSLocationController sharedLocationController].geofence.currentAgency.alternateLogo;
        _alternateLogoImageView = [[TSLogoImageView alloc] initWithImage:image defaultImageName:TSLogoImageViewBigAlternateTapShieldLogo];
        _alternateLogoImageView.preferredHeight = self.navigationController.navigationBar.frame.size.height;

        self.navigationItem.titleView = _alternateLogoImageView;
    }
    else {
        [_alternateLogoImageView removeFromSuperview];
    }
    
    [TSGeofence registerForAgencyProximityUpdates:self action:@selector(updateLogoImages)];
}

- (void)setShowSmallLogoInNavBar:(BOOL)showSmallLogo {
    
    _showSmallLogoInNavBar = showSmallLogo;
    
    if (showSmallLogo) {
        
        UIImage *image = [TSLocationController sharedLocationController].geofence.currentAgency.smallLogo;
        _smallLogoImageView = [[TSLogoImageView alloc] initWithImage:image defaultImageName:TSLogoImageViewSmallTapShieldLogo];
        _smallLogoImageView.preferredHeight = self.navigationController.navigationBar.frame.size.height - 10;
        self.navigationItem.titleView = _smallLogoImageView;
    }
    
    [TSGeofence registerForAgencyProximityUpdates:self action:@selector(updateLogoImages)];
}

- (void)updateLogoImages {
    
    UIImage *image = [TSLocationController sharedLocationController].geofence.currentAgency.largeLogo;
    [_largeLogoImageView setImage:image defaultImageName:TSLogoImageViewBigTapShieldLogo];
    
    image = [TSLocationController sharedLocationController].geofence.currentAgency.alternateLogo;
    [_alternateLogoImageView setImage:image defaultImageName:TSLogoImageViewBigAlternateTapShieldLogo];
    
    image = [TSLocationController sharedLocationController].geofence.currentAgency.smallLogo;
    [_smallLogoImageView setImage:image defaultImageName:TSLogoImageViewSmallTapShieldLogo];
}

#pragma mark - Nav Bars

- (void)whiteNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [UINavigationBar appearance].tintColor = [TSColorPalette tapshieldBlue];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontRalewayMedium size:17.0f] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.3] , NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontRalewayMedium size:17.0f] };
}

- (void)blackNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [UINavigationBar appearance].tintColor = [TSColorPalette whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette whiteColor], NSFontAttributeName : [UIFont fontWithName:kFontRalewayMedium size:17.0f] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette whiteColor], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette whiteColor] colorWithAlphaComponent:0.5] , NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
}

#pragma mark - Table View Customization

- (void)customizeTableView:(UITableView *)tableView {
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Search Bar Customization

- (void)customizeSearchBarAppearance:(UISearchBar *)searchBar {
    
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
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].backgroundColor = [TSColorPalette searchFieldBackgroundColor];
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].font = [TSRalewayFont fontWithName:kFontRalewayMedium size:15.0];
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].textColor = [UIColor whiteColor];
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].tintColor = [UIColor whiteColor];
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].borderStyle = UITextBorderStyleNone;
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    textField.layer.cornerRadius = 3.0f;
    textField.layer.masksToBounds = YES;
    
    searchBar.tintColor = [TSColorPalette tapshieldBlue];
//    searchBar.barTintColor = [TSColorPalette listBackgroundColor];
    
    UIImage *leftViewImage = ((UIImageView *)textField.leftView).image;
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
