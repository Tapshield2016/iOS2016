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

@property (strong, nonatomic) UISearchBar *searchBar;

@property (assign, nonatomic) BOOL searching;
@property (assign, nonatomic) BOOL animating;
@property (assign, nonatomic) BOOL shouldReload;
@property (assign, nonatomic) BOOL movingMember;

@property (strong ,nonatomic) NSIndexPath *selectedRowIndex;

@property (strong, nonatomic) UIButton *editButton;

@property (strong, nonatomic) NSString *filterString;

@property (strong, nonatomic) TSEntourageContactSearchResultsTableViewController *resultsController;

@end

@implementation TSEntourageContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _changesMade = NO;
    _movingMember = NO;
    _shouldReload = NO;
    _animating = NO;
    
    _resultsController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSEntourageContactSearchResultsTableViewController class])];
    _resultsController.contactsTableViewController = self;
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
    
    if (_isEditing) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self getAddressBook];
    [self.refreshControl endRefreshing];
}

- (void)editEntourageMembers {
    
    if (_isEditing) {
        _isEditing = NO;
        [_searchController setActive:NO];
        [self searchBarCancelButtonClicked:_searchBar];
        if (_changesMade) {
            [self syncEntourageMembers];
        }
    }
    else {
        _isEditing = YES;
    }
    
    [self updateEditingButton];
    [_resultsController.tableView reloadData];
    
    [self.tableView setEditing:_isEditing animated:YES];
    [_resultsController setEditing:_isEditing animated:YES];
    
    if (!_isEditing) {
        [self animatePane:_searching];
        return;
    }
    
    [self animatePane:_isEditing];
}

- (void)animatePane:(BOOL)openWide {
    
    TSAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    CGRect frame = self.view.frame;
    if (openWide) {
        if (frame.origin.x == 0) {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                if (_searching) {
                    self.tableView.hidden = YES;
                }
            } completion:nil];
            return;
        }
        [delegate removeAllDrawerAnimations];
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
    [delegate drawerCanDragForContacts:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.frame = frame;
        [self.tableView reloadData];
        [delegate toggleWidePaneState:openWide];
        if (_searching) {
            self.tableView.hidden = YES;
        }
    } completion:^(BOOL finished) {
        [delegate drawerCanDragForContacts:YES];
    }];
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
            NSArray *matchingEntourageArray = [_entourageMembers filteredArrayUsingPredicate:predicate];
            NSArray *whoAddedArray = [_whoAddedUser filteredArrayUsingPredicate:predicate];
            
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
    
    self.allContacts = contacts;
    
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

- (NSArray *)sortedKeyArray:(NSArray *)array {
    
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
            contactArray = _entourageMembers;
            break;
            
        case 1:
            contactArray = _whoAddedUser;
            break;
            
        case 2:
            if (_sortedContacts.allKeys) {
                return nil;
            }
            break;
            
        default:
            
            if (_sortedContacts.allKeys) {
                key = [self sortedKeyArray:_sortedContacts.allKeys][indexPath.section - kContactsSectionOffset];
                contactArray = [_sortedContacts objectForKey:key];
            }
            
            break;
    }
    
    if (!contactArray.count) {
        identifier = emptyCell;
    }
    
    TSEntourageContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TSEntourageContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    
    if (!contactArray.count) {
        [cell emptyCell];
    }
    else {
        cell.contact = contactArray[indexPath.row];
    }
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (!_entourageMembers.count) {
            return NO;
        }
    }
    else if (indexPath.section == 1) {
        if (!_whoAddedUser.count) {
            return NO;
        }
    }
    else if (indexPath.section >= 2) {
        if (!_allContacts.count) {
            return NO;
        }
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:_selectedRowIndex]) {
        [self setIndexPath:indexPath selected:NO];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:_selectedRowIndex]) {
        [self setIndexPath:indexPath selected:NO];
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
    
    if (_movingMember) {
        return;
    }
    _movingMember = YES;
    
    NSMutableArray *minusArray;
    NSMutableArray *plusArray;
    
    BOOL animate = YES;
    NSIndexPath *toIndexPath;
    
    TSJavelinAPIEntourageMember *member;
    
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 0) {
        
        member = [_entourageMembers objectAtIndex:indexPath.row];
        
        if (![self sectionExistsForMember:member]) {
            animate = NO;
        }
        
        plusArray = [[NSMutableArray alloc] initWithArray:_allContacts];
        [plusArray addObject:member];
        self.allContacts = plusArray;
        
        minusArray = [[NSMutableArray alloc] initWithArray:_entourageMembers];
        [minusArray removeObject:member];
        self.entourageMembers = minusArray;
        
        toIndexPath = [self indexPathOfSortedContact:member];
        
        if (!_entourageMembers.count) {
            animate = NO;
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert && indexPath.section == 1) {
        
        member = [_whoAddedUser objectAtIndex:indexPath.row];
        
        plusArray = [[NSMutableArray alloc] initWithArray:_entourageMembers];
        [plusArray addObject:member];
        self.entourageMembers = plusArray;
        animate = NO;
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert && indexPath.section > 1) {
        
        NSString *key = [[self sortedKeyArray:_sortedContacts.allKeys] objectAtIndex:indexPath.section-kContactsSectionOffset];
        NSArray *arrayOfSection = [_sortedContacts objectForKey:key];
        
        if (arrayOfSection.count <= 1 || !_entourageMembers.count) {
            animate = NO;
        }
        
        member = [arrayOfSection objectAtIndex:indexPath.row];
        
        plusArray = [[NSMutableArray alloc] initWithArray:_entourageMembers];
        [plusArray addObject:member];
        self.entourageMembers = plusArray;
        
        minusArray = [[NSMutableArray alloc] initWithArray:_allContacts];
        [minusArray removeObject:member];
        self.allContacts = minusArray;
        
        toIndexPath = [NSIndexPath indexPathForRow:[_entourageMembers indexOfObject:member] inSection:0];
    }
    
    _changesMade = YES;
    
    if (animate && !_animating) {
        _animating = YES;
        [CATransaction begin];
        
        [CATransaction setCompletionBlock:^{
            
            // animation has finished
            _animating = NO;
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
    
    _movingMember = NO;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
            
        case 0:
            if (!_entourageMembers.count) {
                return 1;
            }
            return _entourageMembers.count;
            
        case 1:
            if (!_whoAddedUser.count) {
                return 1;
            }
            return _whoAddedUser.count;
            
        default:
            break;
    }
    
    if (section >= kContactsSectionOffset) {
        if (_sortedContacts.allKeys) {
            NSString *key = [self sortedKeyArray:_sortedContacts.allKeys][section - kContactsSectionOffset];
            NSArray *contactArray = [_sortedContacts objectForKey:key];
            return contactArray.count;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([_selectedRowIndex isEqual:indexPath]) {
        return [TSEntourageContactTableViewCell selectedHeight];
    }
    
    return [TSEntourageContactTableViewCell height];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    tableView.separatorColor = [UIColor clearColor];
    
    return kContactsSectionOffset + _sortedContacts.allKeys.count;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (!_entourageMembers.count) {
            return NO;
        }
    }
    else if (indexPath.section == 1) {
        if (!_whoAddedUser.count) {
            return NO;
        }
    }
    else if (indexPath.section == 2) {
        if (!_allContacts.count) {
            return NO;
        }
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        [self presentMemberSettingsWithMember:[self memberForIndexPath:indexPath]];
    }
    else {
       [self toggleSelectedIndexPath:indexPath];
    }
}

- (TSJavelinAPIEntourageMember *)memberForIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *arrayWithContact;
    
    if (indexPath.section == 0) {
        arrayWithContact = _entourageMembers;
    }
    else if (indexPath.section == 1) {
        arrayWithContact = _whoAddedUser;
    }
    if (indexPath.section >= kContactsSectionOffset) {
        if (_sortedContacts.allKeys) {
            NSString *key = [self sortedKeyArray:_sortedContacts.allKeys][indexPath.section - kContactsSectionOffset];
            arrayWithContact = [_sortedContacts objectForKey:key];
        }
    }
    
    return [arrayWithContact objectAtIndex:indexPath.row];
}

- (void)toggleSelectedIndexPath:(NSIndexPath *)indexPath {
    
    if ([_selectedRowIndex isEqual:indexPath]) {
        [self setIndexPath:indexPath selected:NO];
    }
    else {
        [self setIndexPath:indexPath selected:YES];
    }
}

- (void)setIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    
    if (selected) {
        self.selectedRowIndex = indexPath;
    }
    else {
        _selectedRowIndex = nil;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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
            _editButton.titleLabel.font = [UIFont fontWithName:kFontWeightThin size:16];
            _editButton.titleLabel.textColor = [UIColor whiteColor];
            [_editButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
            [_editButton addTarget:self action:@selector(editEntourageMembers) forControlEvents:UIControlEventTouchUpInside];
        }
        [_editButton removeFromSuperview];
        [fillView addSubview:_editButton];
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
        if (_sortedContacts.allKeys) {
            label.text = [self sortedKeyArray:_sortedContacts.allKeys][section-kContactsSectionOffset];
        }
    }
    
    return view;
}

- (void)updateEditingButton {
    
    _editButton.enabled = YES;
    if (_syncing) {
        [_editButton setTitle:@"Syncing" forState:UIControlStateNormal];
        _editButton.enabled = NO;
    }
    else if (_isEditing) {
        [_editButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    else {
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    [_editButton sizeToFit];
    
    CGRect frame = _editButton.frame;
    frame.origin.x = _editButton.superview.frame.size.width - frame.size.width - 3;
    frame.origin.y = 0;
    frame.size.height = _editButton.superview.frame.size.height;
    _editButton.frame = frame;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:_sortedContacts.allKeys.count+kContactsSectionOffset];
    [mutableArray addObjectsFromArray:@[UITableViewIndexSearch, @"", @"", @"",]];
    [mutableArray addObjectsFromArray:[self sortedKeyArray:_sortedContacts.allKeys]];
    
    return mutableArray;
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
    
    _searching = YES;
    
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
    
    _searchBar.text = @"";
    _searching = NO;
    
    [_searchBar resignFirstResponder];
    
    if (_isEditing) {
        [self.tableView reloadData];
    }
    
    [self animatePane:_isEditing];
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
    entourageMembers = [self sortedMemberArray:entourageMembers];
    _entourageMembers = entourageMembers;
    _resultsController.entourageMembers = entourageMembers;
}

- (void)setWhoAddedUser:(NSArray *)whoAddedUser {
    whoAddedUser = [self sortedMemberArray:whoAddedUser];
    _whoAddedUser = whoAddedUser;
    _resultsController.whoAddedUser = whoAddedUser;
}

- (void)setAllContacts:(NSArray *)allContacts {
    
    allContacts = [self sortedMemberArray:allContacts];
    
    _allContacts = allContacts;
    self.sortedContacts = [self sortContacts:_allContacts];
    
    _resultsController.allContacts = allContacts;
}

- (void)setSortedContacts:(NSMutableDictionary *)sortedContacts {
    
    _sortedContacts = sortedContacts;
    
    _resultsController.sortedContacts = sortedContacts;
}

- (NSIndexPath *)indexPathOfSortedContact:(TSJavelinAPIEntourageMember *)member {
    
    NSString *firstLetter = [member.name substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    
    int section = 0;
    int row = 0;
    for (NSString *string in [self sortedKeyArray:_sortedContacts.allKeys]) {
        if ([string isEqualToString:firstLetter]) {
            NSArray *array = [_sortedContacts objectForKey:string];
            row = [array indexOfObject:member];
            break;
        }
        section++;
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section+kContactsSectionOffset];
}

- (BOOL)sectionExistsForMember:(TSJavelinAPIEntourageMember *)member {
    
    NSString *firstLetter = [member.name substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    
    if ([_sortedContacts objectForKey:firstLetter]) {
        return YES;
    }
    
    return NO;
}

- (void)setSyncing:(BOOL)syncing {
    _syncing = syncing;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateEditingButton];
        [_resultsController updateEditingButton:_isEditing];
    }];
}

- (void)syncEntourageMembers {
    
    _changesMade = NO;
    
    [[TSJavelinAPIClient sharedClient] syncEntourageMembers:_entourageMembers completion:^(id responseObject, NSError *error) {
        
        if (!error) {
            NSLog(@"Saved entourage members");
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)presentMemberSettingsWithMember:(TSJavelinAPIEntourageMember *)member {
    
    TSEntourageMemberSettingsViewController *memberSettings = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSEntourageMemberSettingsViewController class])];
    memberSettings.member = member;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:memberSettings];
    
    [self presentViewController:navController animated:YES completion:nil];
}


#pragma mark Notifications

- (void)entourageDidStartSyncing:(NSNotification *)notification {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
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
    }];
}

@end
