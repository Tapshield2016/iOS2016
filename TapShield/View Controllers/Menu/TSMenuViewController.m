//
//  TSMenuViewController.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSMenuViewController.h"
#import "MSDynamicsDrawerViewController.h"

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
                                                                    @"Profile",
                                                                    @"Settings",
                                                                    @"Help",
                                                                    @"About", nil];

    _viewControllerStoryboardIDs = [[NSMutableArray alloc] initWithObjects: @"TSProfileViewController",
                                                                            @"TSHomeViewController",
                                                                            @"TSMassNotificationsViewController",
                                                                            @"TSProfileViewController",
                                                                            @"TSSettingsViewController",
                                                                            @"TSHelpViewController",
                                                                            @"TSAboutViewController", nil];
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [TSColorPalette charcoalColor];
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
        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(dynamicsDrawerRevealLeftBarButtonItemTapped:)];
    }

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
    [self transitionToViewController:_viewControllerStoryboardIDs[indexPath.row]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_viewControllerStoryboardIDs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TSUserProfileCell *profileCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
        if (profileCell == nil) {
            profileCell = [[TSUserProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProfileCell"];
        }
        
        profileCell.user = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser];
        
        profileCell.backgroundColor = [TSColorPalette charcoalColor];
        profileCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (_viewControllerStoryboardIDs[indexPath.row] == _currentPanelStoryBoardIdentifier) {
            profileCell.selected = YES;
        }
        
        return profileCell;
    }
    
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = _viewControllerTitles[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.alpha = 0.9f;
    cell.textLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:20];
    cell.backgroundColor = [TSColorPalette charcoalColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
    
    if (_viewControllerStoryboardIDs[indexPath.row] == _currentPanelStoryBoardIdentifier) {
        cell.textLabel.textColor = [TSColorPalette tapshieldBlue];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return self.view.frame.size.height/6;
    }
    
    return (self.view.frame.size.height - self.view.frame.size.height/6)/(_viewControllerTitles.count - 1);
}

@end
