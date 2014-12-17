//
//  TSBaseEntourageContactsTableViewController.m
//  TapShield
//
//  Created by Adam Share on 11/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseEntourageContactsTableViewController.h"
#import "TSEntourageContactTableViewCell.h"
#import "TSEntourageMemberSettingsViewController.h"
#import "TSEntourageSessionManager.h"
#import "TSUserNotificationCell.h"
#import "TSAddPhoneNumberCell.h"
#import "TSUserSessionManager.h"

@interface TSBaseEntourageContactsTableViewController ()

@property (assign, nonatomic) BOOL isViewInBackground;
@property (assign, nonatomic) BOOL needsReloadData;

@end

@implementation TSBaseEntourageContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.changesMade = NO;
    self.movingMember = NO;
    self.shouldReload = NO;
    self.animating = NO;
    
    _isViewInBackground = YES;
    _needsReloadData = NO;
    
    self.tableView.sectionIndexColor = [TSColorPalette tapshieldBlue];
    self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexMinimumDisplayRowCount = 10;
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.definesPresentationContext = YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    _isViewInBackground = NO;
    
    if (_needsReloadData) {
        [self reloadTableView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    _isViewInBackground = YES;
}

- (void)setUserNotifications:(NSArray *)userNotifications {
    _userNotifications = userNotifications;
    _staticUserNotifications = _userNotifications;
}

- (void)setEntourageMembers:(NSArray *)entourageMembers {
    _entourageMembers = entourageMembers;
    _staticEntourageMembers = _entourageMembers;
}

- (void)setWhoAddedUser:(NSArray *)whoAddedUser {
    _whoAddedUser = whoAddedUser;
    _staticWhoAddedUser = _whoAddedUser;
}

- (void)setAllContacts:(NSArray *)allContacts {
    
    _allContacts = allContacts;
    _staticAllContacts = _allContacts;
}

- (void)setSortedContacts:(NSMutableDictionary *)sortedContacts {
    
    _sortedContacts = sortedContacts;
    _staticSortedContacts = sortedContacts;
}


- (void)setContactList:(NSArray *)contacts {
    
    self.allContacts = contacts;
    
    [self reloadTableViewOnMainThread];
}

- (void)setFilterString:(NSString *)filterString {
    
    _filterString = filterString;
    
    if (!filterString || filterString.length <= 0) {
        
        if (_entourageMembers.count == _staticEntourageMembers.count &&
            _whoAddedUser.count == _staticWhoAddedUser.count &&
            _allContacts.count == _staticAllContacts.count) {
            return;
        }
        
        _entourageMembers = _staticEntourageMembers;
        _whoAddedUser = _staticWhoAddedUser;
        _allContacts = _staticAllContacts;
        _sortedContacts = _staticSortedContacts;
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@", filterString];
        _entourageMembers = [_staticEntourageMembers filteredArrayUsingPredicate:predicate];
        _whoAddedUser = [_staticWhoAddedUser filteredArrayUsingPredicate:predicate];
        _allContacts = [_staticAllContacts filteredArrayUsingPredicate:predicate];
        _sortedContacts = [self sortContacts:_allContacts];
    }
    
    if (!_shouldMoveCell) {
        
        if (!_animating) {
            _shouldReload = NO;
            [self reloadTableViewOnMainThread];
        }
    }
}

#pragma mark - Sorting

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


#pragma mark - Editing UI

- (void)updateEditingButton {
    
    _editButton.enabled = YES;
    if (self.syncing) {
        [_editButton setTitle:@"Syncing" forState:UIControlStateNormal];
        _editButton.enabled = NO;
    }
    else if (self.editing) {
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

- (void)animatePane:(BOOL)openWide {
    
    TSAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    CGRect frame = self.view.frame;
    if (openWide) {
        if (frame.origin.x == 0) {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                if (self.searching) {
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
        [self reloadTableView];
        [delegate toggleWidePaneState:openWide];
        if (self.searching) {
            self.tableView.hidden = YES;
        }
    } completion:^(BOOL finished) {
        [delegate drawerCanDragForContacts:YES];
    }];
}

- (void)editEntourageMembers {
    
}


#pragma mark - Cell Selection

- (void)setSelectedRowIndex:(NSIndexPath *)selectedRowIndex {
    
    _selectedRowIndex = selectedRowIndex;
    
    if (!selectedRowIndex) {
        _selectedMember = nil;
        [[TSEntourageSessionManager sharedManager] removeCurrentMemberSession];
        return;
    }
    
    _selectedMember = [self memberForIndexPath:selectedRowIndex];
}


- (TSJavelinAPIEntourageMember *)memberForIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *arrayWithContact;
    
    if (indexPath.section == 1) {
        arrayWithContact = self.entourageMembers;
    }
    else if (indexPath.section == 2) {
        arrayWithContact = self.whoAddedUser;
    }
    if (indexPath.section >= kContactsSectionOffset) {
        if (self.sortedContacts.allKeys) {
            NSString *key = [self sortedKeyArray:self.sortedContacts.allKeys][indexPath.section - kContactsSectionOffset];
            arrayWithContact = [self.sortedContacts objectForKey:key];
        }
    }
    
    if (!arrayWithContact.count) {
        return nil;
    }
    
    return [arrayWithContact objectAtIndex:indexPath.row];
}

- (void)toggleSelectedIndexPath:(NSIndexPath *)indexPath {
    
    TSEntourageContactTableViewCell *cell = (TSEntourageContactTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.selectedRowIndex isEqual:indexPath]) {
        [self setIndexPath:indexPath selected:NO];
    }
    else {
        [cell displaySelectedView:YES  animated:YES];
        [self setIndexPath:indexPath selected:YES];
    }
}

- (void)setIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    
    if (selected) {
        self.selectedRowIndex = indexPath;
    }
    else {
        self.selectedRowIndex = nil;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (BOOL)sectionExistsForMember:(TSJavelinAPIEntourageMember *)member {
    
    NSString *firstLetter = [member.name substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    
    if ([self.sortedContacts objectForKey:firstLetter]) {
        return YES;
    }
    
    return NO;
}


- (NSIndexPath *)indexPathOfSortedContact:(TSJavelinAPIEntourageMember *)member {
    
    NSString *firstLetter = [member.name substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    
    NSUInteger section = 0;
    NSUInteger row = 0;
    for (NSString *string in [self sortedKeyArray:self.sortedContacts.allKeys]) {
        if ([string isEqualToString:firstLetter]) {
            NSArray *array = [self.sortedContacts objectForKey:string];
            row = [array indexOfObject:member];
            break;
        }
        section++;
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section+kContactsSectionOffset];
}


#pragma mark - Syncing

- (void)syncEntourageMembers {
    
    self.changesMade = NO;
    
    [[TSJavelinAPIClient sharedClient] syncEntourageMembers:self.staticEntourageMembers completion:^(id responseObject, NSError *error) {
        
        if (!error) {
            NSLog(@"Saved entourage members");
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Member Settings 

- (void)presentMemberSettingsWithMember:(TSJavelinAPIEntourageMember *)member {
    
    TSEntourageMemberSettingsViewController *memberSettings = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSEntourageMemberSettingsViewController class])];
    memberSettings.member = member;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:memberSettings];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:navController animated:YES completion:nil];
    }];
}


#pragma mark - Common TableView

#pragma mark DataSoruce

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        static NSString *notificationTableViewCell = @"notificationTableViewCell";
        
        TSUserNotificationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:notificationTableViewCell];
        
        if (!cell) {
            cell = [[TSUserNotificationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:notificationTableViewCell];
        }
        cell.notification = _userNotifications[indexPath.row];
        return cell;
    }
    
    if (indexPath.section == 2 && !self.isEditing && !self.searching) {
        if (![TSJavelinAPIClient loggedInUser].isPhoneNumberVerified) {
            static NSString *notificationTableViewCell = @"addPhoneNumberCell";
            
            TSAddPhoneNumberCell *cell = [self.tableView dequeueReusableCellWithIdentifier:notificationTableViewCell];
            
            if (!cell) {
                cell = [[TSAddPhoneNumberCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:notificationTableViewCell];
            }
            return cell;
        }
    }
    
    static NSString *entourageContactTableViewCell = @"entourageContactTableViewCell";
    static NSString *emptyCell = @"emptyCell";
    
    NSString *identifier = entourageContactTableViewCell;
    
    TSJavelinAPIEntourageMember *member = [self memberForIndexPath:indexPath];
    
    if (!member) {
        identifier = emptyCell;
    }
    
    TSEntourageContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TSEntourageContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!member) {
        
        [cell emptyCell];
        return cell;
    }
    
    [cell resetAlphas];
    
    switch (indexPath.section) {
        case 1:
            cell.statusImageView.hidden = NO;
            cell.isInEntourage = YES;
            break;
            
        case 2:
            cell.statusImageView.hidden = NO;
            cell.isInEntourage = NO;
            if (!member.location && !member.session && !self.tableView.editing) {
                [cell dimContent];
            }
            break;
            
        default:
            cell.statusImageView.hidden = YES;
            if (!self.tableView.editing) {
                [cell addPlusButton:self];
                [cell dimContent];
            }
            break;
    }
    
    cell.contact = member;
    
    if ([indexPath isEqual:_selectedRowIndex] && [member isEqual:_selectedMember]) {
        if (member.session) {
            [cell setSelected:YES animated:NO];
            [cell displaySelectedView:YES animated:NO];
        }
        else {
            [cell displaySelectedView:NO animated:NO];
        }
    }
    else {
        [cell displaySelectedView:NO animated:NO];
    }
    
    [cell setWidth:self.tableView.frame.size.width];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    }
    
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return nil;
    }
    
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
    frame.origin.x += 16;
    frame.size.width -= 16;
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:kFontWeightLight size:16];
    [view addSubview:label];
    
    if (section == 1) {
        label.text = @"My Entourage";
        
        if (!self.editButton) {
            self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.editButton.titleLabel.font = [UIFont fontWithName:kFontWeightThin size:16];
            self.editButton.titleLabel.textColor = [UIColor whiteColor];
            [self.editButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
            [self.editButton addTarget:self action:@selector(editEntourageMembers) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.editButton removeFromSuperview];
        [fillView addSubview:self.editButton];
        [self updateEditingButton];
    }
    else if (section == 2) {
        label.text = @"Users Who Added Me";
    }
    else if (section == 3) {
        label.text = [NSString stringWithFormat:@"Contacts (%lu)", (unsigned long)self.allContacts.count];
    }
    else if (section >= kContactsSectionOffset) {
        UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        visualEffect.frame = view.frame;
        
        [fillView removeFromSuperview];
        [view insertSubview:visualEffect belowSubview:label];
        if (self.sortedContacts.allKeys) {
            label.text = [self sortedKeyArray:self.sortedContacts.allKeys][section-kContactsSectionOffset];
        }
    }
    
    return view;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:self.sortedContacts.allKeys.count+kContactsSectionOffset];
    [mutableArray addObjectsFromArray:@[UITableViewIndexSearch, @"", @"", @"",]];
    [mutableArray addObjectsFromArray:[self sortedKeyArray:self.sortedContacts.allKeys]];
    
    return mutableArray;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 80;
    }
    
    if (indexPath.section == 2 && ![TSJavelinAPIClient loggedInUser].isPhoneNumberVerified) {
        return 80;
    }
    
    TSJavelinAPIEntourageMember *member = [self memberForIndexPath:indexPath];
    if([self.selectedRowIndex isEqual:indexPath] && [_selectedMember isEqual:member] && member.session) {
        return [TSEntourageContactTableViewCell selectedHeight];
    }
    
    return [TSEntourageContactTableViewCell height];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    tableView.separatorColor = [UIColor clearColor];
    
    return kContactsSectionOffset + self.sortedContacts.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
            
        case 0:
            if (self.isEditing) {
                return 0;
            }
            return self.userNotifications.count;
            
        case 1:
            if (!self.entourageMembers.count) {
                return 1;
            }
            return self.entourageMembers.count;
            
        case 2:
            
            if (![TSJavelinAPIClient loggedInUser].isPhoneNumberVerified) {
                return 1;
            }
            
            if (!self.whoAddedUser.count) {
                return 1;
            }
            return self.whoAddedUser.count;
            
        default:
            break;
    }
    
    if (section >= kContactsSectionOffset) {
        if (self.sortedContacts.allKeys) {
            NSString *key = [self sortedKeyArray:self.sortedContacts.allKeys][section - kContactsSectionOffset];
            NSArray *contactArray = [self.sortedContacts objectForKey:key];
            return contactArray.count;
        }
    }
    
    return 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    
    if (indexPath.section == 1) {
        return UITableViewCellEditingStyleDelete;
    }
    
    if (indexPath.section == 2) {
        if (self.staticEntourageMembers) {
            TSJavelinAPIEntourageMember *member = [self memberForIndexPath:indexPath];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordID == %i", member.recordID];
            NSArray *matchingEntourageArray = [self.staticEntourageMembers filteredArrayUsingPredicate:predicate];
            if (matchingEntourageArray.count) {
                return UITableViewCellEditingStyleNone;
            }
        }
    }
    
    return UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0 && self.tableView.isEditing) {
        return NO;
    }
    
    if (indexPath.section == 1) {
        if (!self.entourageMembers.count) {
            return NO;
        }
    }
    else if (indexPath.section == 2) {
        if (!self.whoAddedUser.count) {
            return NO;
        }
    }
    else if (indexPath.section >= 3) {
        if (!self.allContacts.count) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        if (!self.entourageMembers.count) {
            return NO;
        }
    }
    else if (indexPath.section == 2) {
        
        if (![TSJavelinAPIClient loggedInUser].isPhoneNumberVerified) {
            return YES;
        }
        else if (!self.whoAddedUser.count) {
            return NO;
        }
    }
    else if (indexPath.section >= 3) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        [[TSEntourageSessionManager sharedManager] actionForEntourageNotificationObject:self.userNotifications[indexPath.row]];
    }
    else if (indexPath.section == 1) {
        
        if (self.selectedRowIndex) {
            [[self.tableView cellForRowAtIndexPath:self.selectedRowIndex] setSelected:NO animated:YES];
        }
        self.selectedRowIndex = nil;
        [self presentMemberSettingsWithMember:[self memberForIndexPath:indexPath]];
    }
    else if (indexPath.section == 2) {
        
        if (![TSJavelinAPIClient loggedInUser].isPhoneNumberVerified) {
            [TSUserSessionManager showPhoneVerification];
            return;
        }
        
        TSJavelinAPIEntourageMember *member = [self memberForIndexPath:indexPath];
        if (member.session) {
            [self toggleSelectedIndexPath:indexPath];
        }
        else if (member.location){
            [[TSEntourageSessionManager sharedManager] locateEntourageMember:member];
        }
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:self.selectedRowIndex]) {
        [self setIndexPath:indexPath selected:NO];
    }
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:self.selectedRowIndex]) {
        [self setIndexPath:indexPath selected:NO];
    }
    
    return YES;
}

- (void)reloadTableView {
    
    if (_isViewInBackground) {
        _needsReloadData = YES;
        return;
    }
    
    _needsReloadData = NO;
    
    [self.tableView reloadData];
}

- (void)reloadTableViewOnMainThread {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self reloadTableView];
    }];
}

- (void)moveContactToEntourage:(TSJavelinAPIEntourageMember *)contact {
    
    [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:[self indexPathOfSortedContact:contact]];
}

@end
