//
//  TSBaseViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

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

#pragma mark - Table View Customization

- (void)customizeTableView:(UITableView *)tableView {
    
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.tintColor = [TSColorPalette tapshieldBlue];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.separatorColor = [TSColorPalette cellSeparatorColor];
    tableView.backgroundColor = [TSColorPalette listBackgroundColor];
    [tableView setSectionIndexBackgroundColor:[TSColorPalette tableViewHeaderColor]];
}

#pragma mark - Search Bar Customization

- (void)changeClearButtonStyle:(UISearchBar *)searchBar {
    
    if (!_clearButtonImage) {
        
        for (UIView *view in ((UITextField *)[searchBar.subviews firstObject]).subviews) {
            
            if ([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                
                for (UIButton *button in ((UITextField *)view).subviews) {
                    
                    if ([button isKindOfClass:[UIButton class]]) {
                        
                        _clearButtonImage = [button.imageView.image fillImageWithColor:[UIColor whiteColor]];
                        [button setImage:[button.imageView.image fillImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                        [button setImage:[button.imageView.image fillImageWithColor:[UIColor lightTextColor]] forState:UIControlStateHighlighted];
                        
                    }
                }
            }
        }
    }
}

- (void)customizeSearchBarAppearance:(UISearchBar *)searchBar {
    
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
    searchBar.barTintColor = [TSColorPalette listBackgroundColor];
    
    UIImage *leftViewImage = ((UIImageView *)textField.leftView).image;
    [searchBar setImage:[leftViewImage fillImageWithColor:[UIColor whiteColor]] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
}


@end
