//
//  TSEntourageContactsTableViewController.m
//  TapShield
//
//  Created by Adam Share on 10/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageContactsTableViewController.h"
#import "TSEntourageContactsViewController.h"
#import "TSJavelinAPIEntourageMember.h"
#import "TSEntourageContactTableViewCell.h"
#import "TSEntourageContactSearchResultsTableViewController.h"
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import "TSEntourageMemberSettingsViewController.h"

@class MSDynamicsDrawerViewController;

@interface TSEntourageContactsTableViewController ()

@property (strong, nonatomic) UIView *syncingView;

//@property (strong, nonatomic) UISearchBar *searchBar;
//
//@property (assign, nonatomic) BOOL searching;
//@property (assign, nonatomic) BOOL animating;
//@property (assign, nonatomic) BOOL shouldReload;
//@property (assign, nonatomic) BOOL movingMember;
//
//@property (strong ,nonatomic) NSIndexPath *selectedRowIndex;
//
//@property (strong, nonatomic) UIButton *editButton;
//
//@property (strong, nonatomic) NSString *filterString;
//
@property (strong, nonatomic) TSEntourageContactSearchResultsTableViewController *resultsController;

@end

@implementation TSEntourageContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.changesMade = NO;
    self.movingMember = NO;
    self.shouldReload = NO;
    self.animating = NO;
    
    self.resultsController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSEntourageContactSearchResultsTableViewController class])];
    self.resultsController.contactsTableViewController = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.delegate = self;
    
    // Include the search controller's search bar within the table's header view.
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    visualEffect.frame = self.tableView.tableHeaderView.frame;
    [self.tableView.tableHeaderView insertSubview:visualEffect atIndex:0];
    
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.barStyle = UIBarStyleBlack;
    
    self.definesPresentationContext = YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    [self initRefreshControl];
    
    [self getAddressBook];
    
    self.tableView.sectionIndexColor = [TSColorPalette tapshieldBlue];
    self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexMinimumDisplayRowCount = 10;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(entourageDidFinishSyncing:)
                                                 name:TSJavelinAPIClientDidFinishSyncingEntourage
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(entourageDidStartSyncing:)
                                                 name:TSJavelinAPIClientDidStartSyncingEntourage
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    
    self.selectedRowIndex = nil;
    
    [super viewWillAppear:animated];
    
    [self.refreshControl endRefreshing];
    
    [_resultsController.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[self.view findFirstResponder] resignFirstResponder];
}

- (void)initRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
}

- (void)refresh {
    
    self.selectedRowIndex = nil;
    
    if (self.isEditing) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self getAddressBook];
    [self.refreshControl endRefreshing];
}

- (void)editEntourageMembers {
    
    if (self.isEditing) {
        self.isEditing = NO;
        [self.searchController setActive:NO];
        [self searchBarCancelButtonClicked:self.searchBar];
        if (self.changesMade) {
            [self syncEntourageMembers];
        }
    }
    else {
        self.isEditing = YES;
    }
    
    [self updateEditingButton];
    [_resultsController.tableView reloadData];
    
    [self.tableView setEditing:self.isEditing animated:YES];
    [_resultsController setEditing:self.isEditing animated:YES];
    
    if (!self.isEditing) {
        [self animatePane:self.searching];
        return;
    }
    
    [self animatePane:self.isEditing];
}

- (void)getAddressBook {
    
    self.entourageMembers = [TSJavelinAPIClient loggedInUser].entourageMembers;
    
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    if (error) {
        NSLog(@"error");
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        if (error) {
            NSLog(@"error");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Failed requesting access to contacts"
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            });
            return;
        }
        
        if (!granted) {
            NSLog(@"Denied access");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Contacts Access Denied"
                                            message:@"Please go to\nSettings->Privacy->Contacts\nand enable TapShield"
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            });
            return;
        }
        
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
        CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:nPeople];
        
        for ( CFIndex index = 0; index < nPeople; index++ ) {
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, index );
            
            TSJavelinAPIEntourageMember *member = [[TSJavelinAPIEntourageMember alloc] initWithPerson:person];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordID == %i", member.recordID];
            NSArray *matchingEntourageArray = [self.entourageMembers filteredArrayUsingPredicate:predicate];
            NSArray *whoAddedArray = [self.whoAddedUser filteredArrayUsingPredicate:predicate];
            
            if (!matchingEntourageArray.count && !whoAddedArray.count && (member.phoneNumber || member.email)) {
                [mutableArray addObject:member];
            }
            
            CFRelease(person);
        }
        
        if (mutableArray.count) {
            [self setContactList:mutableArray];
        }
        
        nPeople = ABAddressBookGetPersonCount( addressBook );
        
        CFRelease(allPeople);
        
        if (nPeople == 0) {
            NSLog(@"No contacts with Phone Numbers or Email");
            CFRelease(addressBook);
            return;
        }
    });
}

#pragma mark - Editing UI




#pragma mark - Table View


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.movingMember) {
        return;
    }
    self.movingMember = YES;
    
    NSMutableArray *minusArray;
    NSMutableArray *plusArray;
    
    BOOL animate = YES;
    NSIndexPath *toIndexPath;
    
    TSJavelinAPIEntourageMember *member;
    
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 0) {
        
        member = [self.entourageMembers objectAtIndex:indexPath.row];
        
        if (![self sectionExistsForMember:member]) {
            animate = NO;
        }
        
        plusArray = [[NSMutableArray alloc] initWithArray:self.allContacts];
        [plusArray addObject:member];
        self.allContacts = plusArray;
        
        minusArray = [[NSMutableArray alloc] initWithArray:self.entourageMembers];
        [minusArray removeObject:member];
        self.entourageMembers = minusArray;
        
        toIndexPath = [self indexPathOfSortedContact:member];
        
        if (!self.entourageMembers.count) {
            animate = NO;
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert && indexPath.section == 1) {
        
        member = [self.whoAddedUser objectAtIndex:indexPath.row];
        
        plusArray = [[NSMutableArray alloc] initWithArray:self.entourageMembers];
        [plusArray addObject:member];
        self.entourageMembers = plusArray;
        animate = NO;
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert && indexPath.section > 1) {
        
        NSString *key = [[self sortedKeyArray:self.sortedContacts.allKeys] objectAtIndex:indexPath.section-kContactsSectionOffset];
        NSArray *arrayOfSection = [self.sortedContacts objectForKey:key];
        
        if (arrayOfSection.count <= 1 || !self.entourageMembers.count) {
            animate = NO;
        }
        
        member = [arrayOfSection objectAtIndex:indexPath.row];
        
        plusArray = [[NSMutableArray alloc] initWithArray:self.entourageMembers];
        [plusArray addObject:member];
        self.entourageMembers = plusArray;
        
        minusArray = [[NSMutableArray alloc] initWithArray:self.allContacts];
        [minusArray removeObject:member];
        self.allContacts = minusArray;
        
        toIndexPath = [NSIndexPath indexPathForRow:[self.entourageMembers indexOfObject:member] inSection:0];
    }
    
    self.changesMade = YES;
    
    if (animate && !self.animating) {
        self.animating = YES;
        [CATransaction begin];
        
        [CATransaction setCompletionBlock:^{
            
            // animation has finished
            self.animating = NO;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }];
        
        [self.tableView beginUpdates];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:toIndexPath];
        [self.tableView endUpdates];
        
        [CATransaction commit];
    }
    else {
        [self.tableView reloadData];
    }
    
    self.movingMember = NO;
}




- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index == 0) {
        // search item
        [tableView scrollRectToVisible:[[tableView tableHeaderView] bounds] animated:NO];
        return -1;
    }
    return index;
}


#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    self.searching = YES;
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self animatePane:YES];
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.tableView setHidden:NO];
    
    self.searchBar.text = @"";
    self.searching = NO;
    
    [self.searchBar resignFirstResponder];
    
    if (self.isEditing) {
        [self.tableView reloadData];
    }
    
    [self animatePane:self.isEditing];
}


#pragma mark - Search Controller

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // -updateSearchResultsForSearchController: is called when the controller is being dismissed to allow those who are using the controller they are search as the results controller a chance to reset their state. No need to update anything if we're being dismissed.
    if (!searchController.active) {
        return;
    }
    
    _resultsController.filterString = searchController.searchBar.text;
    
    UIViewController *controller = searchController.searchResultsController;
    if (!controller.view.hidden) {
        self.tableView.hidden = YES;
    }
}

- (void)setEntourageMembers:(NSArray *)entourageMembers {
    [super setEntourageMembers:entourageMembers];
    _resultsController.staticEntourageMembers = self.entourageMembers;
}

- (void)setWhoAddedUser:(NSArray *)whoAddedUser {
    [super setWhoAddedUser:whoAddedUser];
    _resultsController.staticWhoAddedUser = self.whoAddedUser;
}

- (void)setAllContacts:(NSArray *)allContacts {
    
    [super setAllContacts:allContacts];
    _resultsController.staticAllContacts = self.allContacts;
}

- (void)setSortedContacts:(NSMutableDictionary *)sortedContacts {
    
    [super setSortedContacts:sortedContacts];
    _resultsController.staticSortedContacts = sortedContacts;
}



- (void)setSyncing:(BOOL)syncing {
    
    [super setSyncing:syncing];
    _resultsController.syncing = syncing;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateEditingButton];
        [_resultsController updateEditingButton];
    }];
}


- (void)setIsEditing:(BOOL)isEditing {
    
    [super setIsEditing:isEditing];
    
    _resultsController.isEditing = isEditing;
}


#pragma mark Notifications

- (void)entourageDidStartSyncing:(NSNotification *)notification {
    
    CGRect entourageFrame = CGRectZero;
    entourageFrame.origin.y = self.tableView.tableHeaderView.frame.size.height + 35;
    
    if (self.entourageMembers.count) {
        entourageFrame.size.height = self.entourageMembers.count*[TSEntourageContactTableViewCell height];
    }
    else {
        entourageFrame.size.height = [TSEntourageContactTableViewCell height];
    }
    
    entourageFrame.size.width = self.tableView.frame.size.width;
    
    _syncingView = [[UIView alloc] initWithFrame:entourageFrame];
    _syncingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = _syncingView.contentCenter;
    [_syncingView addSubview:indicator];
    [indicator startAnimating];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView addSubview:_syncingView];
        [self.refreshControl beginRefreshing];
        [self setSyncing:YES];
    }];
}

- (void)entourageDidFinishSyncing:(NSNotification *)notification {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.refreshControl endRefreshing];
        [self setSyncing:NO];
        self.entourageMembers = [TSJavelinAPIClient loggedInUser].entourageMembers;
        [self.tableView reloadData];
        [_syncingView removeFromSuperview];
    }];
}

@end
