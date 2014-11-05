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

@interface TSEntourageContactsTableViewController ()

@property (strong, nonatomic) UISearchBar *searchBar;
@property (assign, nonatomic) BOOL searching;
@property (assign, nonatomic) BOOL editing;
@property (strong, nonatomic) UIButton *editButton;
@property (nonatomic, strong) NSMutableArray *searchResult;

@property (strong, nonatomic) NSString *filterString;
@property (strong, nonatomic) NSArray *visibleEntourageMembers;
@property (strong, nonatomic) NSArray *visibleWhoAddedUser;
@property (strong, nonatomic) NSArray *visibleAllContacts;
@property (strong, nonatomic) NSMutableDictionary *visibleSortedContacts;

@end

@implementation TSEntourageContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.delegate = self;
    
    // Include the search controller's search bar within the table's header view.
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    
    UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    visualEffect.frame = self.tableView.tableHeaderView.frame;
    [self.tableView.tableHeaderView insertSubview:visualEffect atIndex:0];
    
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.barStyle = UIBarStyleBlack;
    
    self.definesPresentationContext = YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    [self getAddressBook];
    
    self.tableView.sectionIndexColor = [TSColorPalette tapshieldBlue];
    self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    self.searchResult = [NSMutableArray arrayWithCapacity:10];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.refreshControl endRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[self.view findFirstResponder] resignFirstResponder];
}

- (void)refresh {
    [self getAddressBook];
    [self.refreshControl endRefreshing];
}

- (void)editEntourageMembers {
    
    if (_editing) {
        _editing = NO;
    }
    else {
        _editing = YES;
    }
    
    [self updateEditingButton];
    
    [self.tableView setEditing:_editing animated:YES];
    
    if (!_editing) {
        [self animatePane:_searching];
        return;
    }
    
    [self animatePane:_editing];
}

- (void)animatePane:(BOOL)openWide {
    
    TSAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    CGRect frame = self.view.frame;
    if (openWide) {
        if (frame.origin.x == 0) {
            return;
        }
        frame.origin.x = 0;
        frame.size.width = self.view.superview.frame.size.width;
    }
    else {
        if (frame.origin.x == 50) {
            return;
        }
        frame.origin.x = 50;
        frame.size.width = self.view.superview.frame.size.width - 50;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = frame;
        [delegate toggleWidePaneState:openWide];
        [self.tableView reloadData];
    } completion:nil];
    
    
}

- (void)getAddressBook {
    
    self.entourageMembers = [self sortedMemberArray:[TSJavelinAPIClient loggedInUser].entourageMembers];
    
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
            NSArray *matchingEntourageArray = [[_entourageMembers copy] filteredArrayUsingPredicate:predicate];
            NSArray *whoAddedArray = [[_whoAddedUser copy] filteredArrayUsingPredicate:predicate];
            
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

- (void)setContactList:(NSArray *)contacts {
    
    self.allContacts = [self sortedMemberArray:contacts];
    
    self.sortedContacts = [self sortContacts:_allContacts];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}


- (NSMutableDictionary *)sortContacts:(NSArray *)contacts {
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    for (TSJavelinAPIEntourageMember *member in contacts) {
        NSString *firstLetter = [[member.name substringToIndex:1] uppercaseString];
        
        if ([mutableDictionary objectForKey:firstLetter]) {
            NSMutableArray *mutableArray = [mutableDictionary objectForKey:firstLetter];
            [mutableArray addObject:member];
        }
        else {
            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:5];
            [mutableArray addObject:member];
            [mutableDictionary setObject:mutableArray forKey:firstLetter];
        }
    }
    
    return mutableDictionary;
}


- (NSArray *)sortedMemberArray:(NSArray *)array {
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    return [array sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray *)sortedArray:(NSArray *)array {
    
    return [array sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];;
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *entourageContactTableViewCell = @"entourageContactTableViewCell";
    static NSString *emptyCell = @"emptyCell";
    
    NSString *identifier = entourageContactTableViewCell;
    
    NSArray *contactArray;
    NSString *key;
    
    switch (indexPath.section) {
        case 0:
            contactArray = _visibleEntourageMembers;
            break;
            
        case 1:
            contactArray = _visibleWhoAddedUser;
            break;
            
        case 2:
            if (_visibleSortedContacts.allKeys) {
                return nil;
            }
            break;
            
        default:
            
            if (_visibleSortedContacts.allKeys) {
                key = [self sortedArray:_visibleSortedContacts.allKeys][indexPath.section - 3];
                contactArray = [_visibleSortedContacts objectForKey:key];
            }
            
            break;
    }
    
    if (!contactArray.count) {
        identifier = emptyCell;
    }
    
    TSEntourageContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:entourageContactTableViewCell];
    
    if (!cell) {
        cell = [[TSEntourageContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:entourageContactTableViewCell];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    
    if (!contactArray.count) {
        [cell emptyCell];
    }
    else {
        cell.contact = contactArray[indexPath.row];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (!_visibleEntourageMembers.count) {
            return NO;
        }
    }
    else if (indexPath.section == 1) {
        if (!_visibleWhoAddedUser.count) {
            return NO;
        }
    }
    else if (indexPath.section >= 2) {
        if (!_visibleAllContacts.count) {
            return NO;
        }
    }
    
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
            
        case 0:
            if (![self sortedMemberArray:_visibleEntourageMembers].count) {
                return 1;
            }
            return [self sortedMemberArray:_visibleEntourageMembers].count;
            
        case 1:
            if (!_visibleWhoAddedUser.count) {
                return 1;
            }
            return _visibleWhoAddedUser.count;
            
        default:
            break;
    }
    
    if (section >= 3) {
        if (_visibleSortedContacts.allKeys) {
            NSString *key = [self sortedArray:_visibleSortedContacts.allKeys][section - 3];
            NSArray *contactArray = [_visibleSortedContacts objectForKey:key];
            return contactArray.count;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    tableView.separatorColor = [UIColor clearColor];
    
    return 3 + _visibleSortedContacts.allKeys.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    float height = 35;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width - 15, height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *fillView = [[UIView alloc] initWithFrame:view.frame];
    fillView.backgroundColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.9];
    
    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = CGSizeMake(0, 3);
    view.layer.shadowRadius = 5;
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    [view addSubview:fillView];
    
    
    CGRect frame = view.frame;
    frame.origin.x += 20;
    frame.size.width -= 40;
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:kFontWeightLight size:16];
    [view addSubview:label];
    
    if (section == 0) {
        label.text = @"Entourage";
        
        if (!_editButton) {
            _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        }
        [_editButton removeFromSuperview];
        [view addSubview:_editButton];
        [self updateEditingButton];
    }
    else if (section == 1) {
        label.text = @"Users Who Added You";
    }
    else if (section == 2) {
        label.text = @"All Contacts";
    }
    else {
        UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        visualEffect.frame = view.frame;
        
        [fillView removeFromSuperview];
        [view insertSubview:visualEffect belowSubview:label];
        if (_visibleSortedContacts.allKeys) {
            label.text = [self sortedArray:_visibleSortedContacts.allKeys][section-3];
        }
    }
    
    return view;
}

- (void)updateEditingButton {
    
    if (_editing) {
        [_editButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    else {
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    _editButton.titleLabel.font = [UIFont fontWithName:kFontWeightThin size:16];
    _editButton.titleLabel.textColor = [UIColor whiteColor];
    [_editButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [_editButton addTarget:self action:@selector(editEntourageMembers) forControlEvents:UIControlEventTouchUpInside];
    [_editButton sizeToFit];
    
    CGRect frame = _editButton.frame;
    frame.origin.x = _editButton.superview.frame.size.width - frame.size.width - 3;
    frame.origin.y = 0;
    frame.size.height = _editButton.superview.frame.size.height;
    _editButton.frame = frame;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:_visibleSortedContacts.allKeys.count+3];
    [mutableArray addObjectsFromArray:@[UITableViewIndexSearch, @"", @"", @"",]];
    [mutableArray addObjectsFromArray:[self sortedArray:_visibleSortedContacts.allKeys]];
    
    return mutableArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return index;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    _searching = YES;
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
//    [self performSelector:@selector(setContentInsetDelayed) withObject:nil afterDelay:0.3];
    
    [self animatePane:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    _searchBar.text = @"";
    _searching = NO;
    
    [_searchBar resignFirstResponder];
    
    [self animatePane:_editing];
}

- (void)setContentInsetDelayed {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.tableView.tableHeaderView = nil;
//        [self.tableView setContentOffset:CGPointMake(0,0) animated:YES];
        self.tableView.contentInset = UIEdgeInsetsMake(43, 0, 0, 0);
    }];
}


#pragma mark - Search Controller

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // -updateSearchResultsForSearchController: is called when the controller is being dismissed to allow those who are using the controller they are search as the results controller a chance to reset their state. No need to update anything if we're being dismissed.
    if (!searchController.active) {
        return;
    }
    
    self.filterString = searchController.searchBar.text;
}

- (void)setEntourageMembers:(NSArray *)entourageMembers {
    
    _entourageMembers = entourageMembers;
    self.visibleEntourageMembers = _entourageMembers;
    
    if (_filterString) {
        [self setFilterString:_filterString];
    }
}

- (void)setWhoAddedUser:(NSArray *)whoAddedUser {
    
    _whoAddedUser = whoAddedUser;
    self.visibleWhoAddedUser = whoAddedUser;
    
    if (_filterString) {
        [self setFilterString:_filterString];
    }
}

- (void)setAllContacts:(NSArray *)allContacts {
    
    _allContacts = allContacts;
    self.visibleAllContacts = allContacts;
    
    if (_filterString) {
        [self setFilterString:_filterString];
    }
}

- (void)setSortedContacts:(NSMutableDictionary *)sortedContacts {
    
    _sortedContacts = sortedContacts;
    self.visibleSortedContacts = sortedContacts;
    
    if (_filterString) {
        [self setFilterString:_filterString];
    }
}

- (void)setFilterString:(NSString *)filterString {
    _filterString = filterString;
    
    if (!filterString || filterString.length <= 0) {
        self.visibleEntourageMembers = _entourageMembers;
        self.visibleWhoAddedUser = _whoAddedUser;
        self.visibleAllContacts = _allContacts;
        self.visibleSortedContacts = _sortedContacts;
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@", filterString];
        self.visibleEntourageMembers = [_entourageMembers filteredArrayUsingPredicate:predicate];
        self.visibleWhoAddedUser = [_whoAddedUser filteredArrayUsingPredicate:predicate];
        self.visibleAllContacts = [_allContacts filteredArrayUsingPredicate:predicate];
        self.visibleSortedContacts = [self sortContacts:self.visibleAllContacts];
    }
    
    [self.tableView reloadData];
}




@end
