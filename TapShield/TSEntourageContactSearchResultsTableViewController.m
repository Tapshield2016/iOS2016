//
//  TSEntourageContactSearchResultsTableViewController.m
//  TapShield
//
//  Created by Adam Share on 10/31/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageContactSearchResultsTableViewController.h"
#import "TSEntourageContactsViewController.h"
#import "TSJavelinAPIEntourageMember.h"
#import "TSEntourageContactTableViewCell.h"
#import "TSEntourageMemberSettingsViewController.h"

@interface TSEntourageContactSearchResultsTableViewController ()

@property (strong, nonatomic) UIButton *editButton;
@property (assign, nonatomic) BOOL shouldMoveCell;
@property (assign, nonatomic) BOOL animating;
@property (assign, nonatomic) BOOL shouldReload;
@property (assign, nonatomic) BOOL movingMember;
@property (assign, nonatomic) BOOL viewWillAppear;
@property (strong, nonatomic) NSArray *visibleEntourageMembers;
@property (strong, nonatomic) NSArray *visibleWhoAddedUser;
@property (strong, nonatomic) NSArray *visibleAllContacts;
@property (strong, nonatomic) NSMutableDictionary *visibleSortedContacts;

@property (strong ,nonatomic) NSIndexPath *selectedRowIndex;

@end

@implementation TSEntourageContactSearchResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _shouldMoveCell = NO;
    _shouldReload = NO;
    _animating = NO;
    _movingMember = NO;
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = YES;
    
    self.tableView.sectionIndexColor = [TSColorPalette tapshieldBlue];
    self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexMinimumDisplayRowCount = 6;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            contactArray = _visibleEntourageMembers;
            break;
            
        case 1:
            contactArray = _visibleWhoAddedUser;
            break;
            
        case 2:
            if (!_visibleAllContacts) {
                contactArray = _visibleAllContacts;
                break;
            }
            break;
            
        default:
            
            if (_visibleSortedContacts.allKeys) {
                key = [self sortedKeyArray:_visibleSortedContacts.allKeys][indexPath.section - kContactsSectionOffset];
                contactArray = [_visibleSortedContacts objectForKey:key];
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
    
    if (_movingMember) {
        return;
    }
    
    _movingMember = YES;
    
    NSMutableArray *minusArray;
    NSMutableArray *plusArray;
    
    _shouldMoveCell = YES;
    NSIndexPath *toIndexPath;
    
    TSJavelinAPIEntourageMember *member;
    
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 0) {
        
        if (!_visibleEntourageMembers.count) {
            _movingMember = NO;
            _shouldMoveCell = NO;
            [self.tableView reloadData];
            return;
        }
        
        member = [_visibleEntourageMembers objectAtIndex:indexPath.row];
        
        if (![self sectionExistsForMember:member] || _visibleEntourageMembers.count <= 1) {
            _shouldMoveCell = NO;
        }
        
        plusArray = [[NSMutableArray alloc] initWithArray:_allContacts];
        [plusArray addObject:member];
        _contactsTableViewController.allContacts = plusArray;
        
        minusArray = [[NSMutableArray alloc] initWithArray:_entourageMembers];
        [minusArray removeObject:member];
        _contactsTableViewController.entourageMembers = minusArray;
        
        toIndexPath = [self indexPathOfSortedContact:member];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert && indexPath.section == 1) {
        
        _shouldMoveCell = NO;
        member = [_visibleWhoAddedUser objectAtIndex:indexPath.row];
        
        plusArray = [[NSMutableArray alloc] initWithArray:_entourageMembers];
        [plusArray addObject:member];
        _contactsTableViewController.entourageMembers = plusArray;
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert && indexPath.section > 1) {
        
        NSString *key = [[self sortedKeyArray:_visibleSortedContacts.allKeys] objectAtIndex:indexPath.section-kContactsSectionOffset];
        NSArray *arrayOfSection = [_visibleSortedContacts objectForKey:key];
        
        if (arrayOfSection.count <= 1 || !_visibleEntourageMembers.count) {
            _shouldMoveCell = NO;
        }
        
        member = [arrayOfSection objectAtIndex:indexPath.row];
        
        plusArray = [[NSMutableArray alloc] initWithArray:_entourageMembers];
        [plusArray addObject:member];
        _contactsTableViewController.entourageMembers = plusArray;
        
        minusArray = [[NSMutableArray alloc] initWithArray:_allContacts];
        [minusArray removeObject:member];
        _contactsTableViewController.allContacts = minusArray;
        
        toIndexPath = [NSIndexPath indexPathForRow:[_visibleEntourageMembers indexOfObject:member] inSection:0];
    }
    
    _contactsTableViewController.changesMade = YES;
    if (_shouldMoveCell && !_animating) {
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
    
    [_contactsTableViewController.tableView reloadData];
    
    _movingMember = NO;
    _shouldMoveCell = NO;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
            
        case 0:
            if (!_visibleEntourageMembers.count) {
                return 1;
            }
            return _visibleEntourageMembers.count;
            
        case 1:
            if (!_visibleWhoAddedUser.count) {
                return 1;
            }
            return _visibleWhoAddedUser.count;
            
        case 2:
            if (!_visibleAllContacts.count) {
                return 1;
            }
            
        default:
            break;
    }
    
    if (section >= kContactsSectionOffset) {
        if (_visibleSortedContacts.allKeys) {
            NSString *key = [self sortedKeyArray:_visibleSortedContacts.allKeys][section - kContactsSectionOffset];
            NSArray *contactArray = [_visibleSortedContacts objectForKey:key];
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
    
    return kContactsSectionOffset + _visibleSortedContacts.allKeys.count;
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
            if ([_contactsTableViewController respondsToSelector:@selector(editEntourageMembers)]) {
                [_editButton addTarget:_contactsTableViewController action:@selector(editEntourageMembers) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        [_editButton removeFromSuperview];
        [fillView addSubview:_editButton];
        [self updateEditingButton:_contactsTableViewController.isEditing];
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
            label.text = [self sortedKeyArray:_visibleSortedContacts.allKeys][section-kContactsSectionOffset];
        }
    }
    
    return view;
}


- (void)updateEditingButton:(BOOL)editing {
    
    _editButton.enabled = YES;
    if (_contactsTableViewController.syncing) {
        [_editButton setTitle:@"Syncing" forState:UIControlStateNormal];
        _editButton.enabled = NO;
    }
    else if (editing) {
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
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:_visibleSortedContacts.allKeys.count+kContactsSectionOffset];
    [mutableArray addObjectsFromArray:@[UITableViewIndexSearch, @"", @"", @"",]];
    [mutableArray addObjectsFromArray:[self sortedKeyArray:_visibleSortedContacts.allKeys]];
    
    return mutableArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return index;
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
        
        if (self.visibleEntourageMembers.count == _entourageMembers.count &&
            self.visibleWhoAddedUser.count == _whoAddedUser.count &&
            self.visibleAllContacts.count == _allContacts.count) {
            return;
        }
        
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
    
    if (!_shouldMoveCell) {
        
        if (!_animating) {
            _shouldReload = NO;
            [self.tableView reloadData];
        }
    }
}

- (NSIndexPath *)indexPathOfSortedContact:(TSJavelinAPIEntourageMember *)member {
    
    NSString *firstLetter = [member.name substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    
    int section = 0;
    int row = 0;
    for (NSString *string in [self sortedKeyArray:_visibleSortedContacts.allKeys]) {
        if ([string isEqualToString:firstLetter]) {
            NSArray *array = [_visibleSortedContacts objectForKey:string];
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
    
    if ([_visibleSortedContacts objectForKey:firstLetter]) {
        return YES;
    }
    
    return NO;
}


#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0f, keyboardBounds.size.height, 0.0f);
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        [self presentMemberSettingsWithMember:[self memberForIndexPath:indexPath]];
    }
    else {
        [self toggleSelectedIndexPath:indexPath];
    }
}

- (void)presentMemberSettingsWithMember:(TSJavelinAPIEntourageMember *)member {
    
    TSEntourageMemberSettingsViewController *memberSettings = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSEntourageMemberSettingsViewController class])];
    memberSettings.member = member;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:memberSettings];
    
    [self presentViewController:navController animated:YES completion:nil];
}


- (TSJavelinAPIEntourageMember *)memberForIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *arrayWithContact;
    
    if (indexPath.section == 0) {
        arrayWithContact = _visibleEntourageMembers;
    }
    else if (indexPath.section == 1) {
        arrayWithContact = _visibleWhoAddedUser;
    }
    if (indexPath.section >= kContactsSectionOffset) {
        if (_visibleSortedContacts.allKeys) {
            NSString *key = [self sortedKeyArray:_visibleSortedContacts.allKeys][indexPath.section - kContactsSectionOffset];
            arrayWithContact = [_visibleSortedContacts objectForKey:key];
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

@end
