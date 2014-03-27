//
//  TSMenuViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMenuViewController.h"
#import "MSDynamicsDrawerViewController.h"

#define MENU_CELL_SIZE 80

@interface TSMenuViewController ()

@property (nonatomic, strong) NSString *currentPanelStoryBoardIdentifier;
@property (nonatomic, strong) NSMutableArray *viewControllerStoryboardIDs;
@property (nonatomic, strong) NSMutableArray *viewControllerTitles;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;

@end

@implementation TSMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

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
    [self.tableView registerClass:[TSUserProfileCell class]  forCellReuseIdentifier:@"ProfileCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)transitionToViewController:(NSString *)storyBoardIdentifier {
    
    if (storyBoardIdentifier == _currentPanelStoryBoardIdentifier) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:YES completion:nil];
        return;
    }
    
    if (!_leftBarButtonItem) {
        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(dynamicsDrawerRevealLeftBarButtonItemTapped:)];    }

    BOOL animateTransition = self.dynamicsDrawerViewController.paneViewController != nil;
    UIViewController *paneViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyBoardIdentifier];
    UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
    [self.dynamicsDrawerViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];

    paneViewController.navigationItem.leftBarButtonItem = _leftBarButtonItem;

    _currentPanelStoryBoardIdentifier = storyBoardIdentifier;
}

- (void)dynamicsDrawerRevealLeftBarButtonItemTapped:(id)sender {
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self transitionToViewController:[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return [_viewControllerStoryboardIDs count];
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.textLabel.text = _viewControllerTitles[indexPath.row];
//    cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
//    cell.textLabel.font = [UIFont fontWithName:kFontRalewayRegular size:20];
//    cell.backgroundColor = [TSColorPalette clearColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    
//    if (_viewControllerStoryboardIDs[indexPath.row] == _currentPanelStoryBoardIdentifier) {
//        cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
//    }
//    
//    return cell;
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    float dimAlpha = 0.5f;
    
    cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:dimAlpha];
    cell.textLabel.font = [UIFont fontWithName:kFontRalewayRegular size:20];
    cell.backgroundColor = [TSColorPalette clearColor];
    cell.imageView.alpha = dimAlpha;
    
    if ([cell.reuseIdentifier isEqualToString:_currentPanelStoryBoardIdentifier]) {
        cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
        cell.imageView.alpha = 1.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 || indexPath.row == 6) {
        
        return ([UIScreen mainScreen].bounds.size.height - MENU_CELL_SIZE * 5)/2;
    }
    
    return MENU_CELL_SIZE;
}

@end
