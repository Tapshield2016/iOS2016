//
//  TSMenuViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMenuViewController.h"
#import "MSDynamicsDrawerViewController.h"
#import "TSHomeViewController.h"
#import "TSYankManager.h"
#import "TSSettingsViewController.h"
#import "TSVirtualEntourageManager.h"
#import "TSHelpViewController.h"

#define MENU_CELL_SIZE 80

@interface TSMenuViewController ()

@property (nonatomic, strong) NSString *currentPanelStoryBoardIdentifier;
@property (nonatomic, strong) NSMutableArray *viewControllerStoryboardIDs;
@property (nonatomic, strong) NSMutableArray *viewControllerTitles;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIWindow *mailWindow;

@end

@implementation TSMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnToMapViewForYankAlert)
                                                 name:TSYankManagerDidYankHeadphonesNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnToMapViewForLogOut)
                                                 name:TSSettingsViewControllerDidLogOut
                                               object:nil];
    

    _viewControllerTitles = [[NSMutableArray alloc] initWithObjects:@"Profile",
                                                                    @"Home",
                                                                    @"Mass Notifications",
                                                                    @"Settings",
                                                                    @"Help",
                                                                    @"About", nil];

    _viewControllerStoryboardIDs = [[NSMutableArray alloc] initWithObjects: @"TSProfileViewController",
                                                                            @"TSHomeViewController",
                                                                            @"TSMassNotificationsViewController",
                                                                            @"TSSettingsViewController",
                                                                            @"TSHelpViewController",
                                                                            @"TSAboutViewController", nil];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)returnToMapViewForYankAlert {
    
    if ([NSStringFromClass([TSHomeViewController class]) isEqualToString:_currentPanelStoryBoardIdentifier]) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:nil];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        TSHomeViewController *homeView = (TSHomeViewController *)[self transitionToViewController:NSStringFromClass([TSHomeViewController class]) animated:NO];
        homeView.shouldSendAlert = YES;
        [self.tableView reloadData];
    });
}

- (void)returnToMapViewForLogOut {
    
    if ([NSStringFromClass([TSHomeViewController class]) isEqualToString:_currentPanelStoryBoardIdentifier]) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:nil];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self transitionToViewController:NSStringFromClass([TSHomeViewController class]) animated:YES];
        [self.tableView reloadData];
    });
}

- (UIViewController *)transitionToViewController:(NSString *)storyBoardIdentifier animated:(BOOL)animated {
    
    if (!storyBoardIdentifier) {
        return nil;
    }
    
    if ([storyBoardIdentifier isEqualToString:_currentPanelStoryBoardIdentifier]) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:YES completion:nil];
        return nil;
    }

    BOOL animateTransition = self.dynamicsDrawerViewController.paneViewController != nil;
    if (animated) {
        animated = animateTransition;
    }
    
    UIViewController *paneViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyBoardIdentifier];
    UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
    [paneNavigationViewController setNavigationBarHidden:YES];
    
    UIViewController *oldPane = self.dynamicsDrawerViewController.paneViewController;
    if ([oldPane isKindOfClass:[UINavigationController class]]) {
        oldPane = [(UINavigationController *)oldPane topViewController];
    }
    [oldPane willMoveToParentViewController:nil];
    [self.dynamicsDrawerViewController setPaneViewController:paneNavigationViewController animated:animated completion:nil];

    [self showMenuButton:paneViewController];
    
    if ([paneViewController isKindOfClass:[TSHomeViewController class]]) {
        ((TSHomeViewController *)paneViewController).menuViewController = self;
    }

    _currentPanelStoryBoardIdentifier = storyBoardIdentifier;
    
    return paneViewController;
}

- (void)dynamicsDrawerRevealLeftBarButtonItemTapped:(id)sender {
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}

- (void)showMenuButton:(UIViewController *)viewController {
    
    if (!_leftBarButtonItem) {
        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(dynamicsDrawerRevealLeftBarButtonItemTapped:)];
    }
    
    [viewController.navigationItem setLeftBarButtonItem:_leftBarButtonItem animated:NO];
}

- (IBAction)showAbout:(id)sender {
    
    [self.tableView reloadData];
    [self transitionToViewController:@"TSAboutViewController" animated:YES];
}

- (IBAction)sendFeedback:(id)sender {
    NSString *emailTitle = @"TapShield iOS App Feedback";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"hello@tapshield.com"];
    
    _mailWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_mailWindow setWindowLevel:UIWindowLevelAlert];
    _mailWindow.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*1.5);
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    // Present mail view controller on screen
    
    [_mailWindow setRootViewController:mc];
    [_mailWindow makeKeyAndVisible];
    _mailWindow.transform = CGAffineTransformMakeScale(0.25, 0.25);
    [UIView animateWithDuration:0.3f animations:^{
        _mailWindow.transform = CGAffineTransformMakeScale(1.0, 1.0);
        _mailWindow.center = self.view.center;
    }];
//    [self presentViewController:mc animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    // Close the Mail Interface
//    [controller dismissViewControllerAnimated:YES completion:nil];
    
    [UIView animateWithDuration:0.3f animations:^{
        _mailWindow.transform = CGAffineTransformMakeScale(0.25, 0.25);
        _mailWindow.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*1.5);
    } completion:^(BOOL finished) {
        _mailWindow = nil;
    }];
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self transitionToViewController:[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier animated:YES];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell.textLabel.text isEqualToString:@"Profile"]) {
        UIImage *image = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].userProfile.profileImage;
        if (image) {
            CGSize size = cell.imageView.bounds.size;
            cell.imageView.image = [[image imageWithRoundedCornersRadius:image.size.height/2] resizeToSize:size];
        }
    }
    cell.imageView.layer.cornerRadius = cell.imageView.bounds.size.height/2;
    cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.imageView.layer.borderWidth = 1.0f;
    cell.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.imageView.layer.shadowRadius = 1.0f;
    cell.imageView.layer.shadowOpacity = 1;
    cell.imageView.layer.shadowOffset = CGSizeZero;
    
    float dimAlpha = 0.5f;
    
    cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:dimAlpha];
    cell.textLabel.font = [UIFont fontWithName:kFontRalewayRegular size:20];
    cell.backgroundColor = [TSColorPalette clearColor];
    cell.imageView.alpha = dimAlpha;
    
    if ([cell.reuseIdentifier isEqualToString:_currentPanelStoryBoardIdentifier]) {
        cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
        cell.imageView.alpha = 1.0f;
    }
    
    if ([cell.reuseIdentifier isEqualToString:NSStringFromClass([TSHelpViewController class])]) {
        if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.infoUrl.length) {
            cell.textLabel.text = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.name;
            [cell setHidden:NO];
        }
        else {
            [cell setHidden:YES];
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 || indexPath.row == 6) {
        
        return ([UIScreen mainScreen].bounds.size.height - MENU_CELL_SIZE * 5)/2;
    }
    
    return MENU_CELL_SIZE;
}

@end
