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
#import "TSEntourageContactsTableViewController.h"

@interface TSEntourageContactSearchResultsTableViewController ()

@end

@implementation TSEntourageContactSearchResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = YES;
    
    self.tableView.sectionIndexColor = [TSColorPalette tapshieldBlue];
    self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexMinimumDisplayRowCount = 6;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(44, 0.0f, 0.0f, 0.0f);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
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

- (void)editEntourageMembers {
    
    [_contactsTableViewController editEntourageMembers];
}

- (void)setChangesMade:(BOOL)changesMade {
    
    [super setChangesMade:changesMade];
    
    if (changesMade != _contactsTableViewController.changesMade) {
        _contactsTableViewController.changesMade = changesMade;
    }
}

#pragma mark - Table View


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.movingMember) {
        return;
    }
    
    self.movingMember = YES;
    
    NSMutableArray *minusArray;
    NSMutableArray *plusArray;
    
    self.shouldMoveCell = YES;
    NSIndexPath *toIndexPath;
    
    TSJavelinAPIEntourageMember *member;
    
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 0) {
        
        if (!self.entourageMembers.count) {
            self.movingMember = NO;
            self.shouldMoveCell = NO;
            [self.tableView reloadData];
            return;
        }
        
        member = [self.entourageMembers objectAtIndex:indexPath.row];
        
        if (![self sectionExistsForMember:member] || self.entourageMembers.count <= 1 || !self.isEditing) {
            self.shouldMoveCell = NO;
        }
        
        plusArray = [[NSMutableArray alloc] initWithArray:self.staticAllContacts];
        [plusArray addObject:member];
        _contactsTableViewController.allContacts = plusArray;
        
        minusArray = [[NSMutableArray alloc] initWithArray:self.staticEntourageMembers];
        [minusArray removeObject:member];
        _contactsTableViewController.entourageMembers = minusArray;
        
        toIndexPath = [self indexPathOfSortedContact:member];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert && indexPath.section == 1) {
        
        self.shouldMoveCell = NO;
        member = [self.whoAddedUser objectAtIndex:indexPath.row];
        
        plusArray = [[NSMutableArray alloc] initWithArray:self.staticEntourageMembers];
        [plusArray addObject:member];
        _contactsTableViewController.entourageMembers = plusArray;
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert && indexPath.section > 1) {
        
        NSString *key = [[self sortedKeyArray:self.sortedContacts.allKeys] objectAtIndex:indexPath.section-kContactsSectionOffset];
        NSArray *arrayOfSection = [self.sortedContacts objectForKey:key];
        
        if (arrayOfSection.count <= 1 || !self.entourageMembers.count || !self.isEditing) {
            self.shouldMoveCell = NO;
        }
        
        member = [arrayOfSection objectAtIndex:indexPath.row];
        
        plusArray = [[NSMutableArray alloc] initWithArray:self.staticEntourageMembers];
        [plusArray addObject:member];
        _contactsTableViewController.entourageMembers = plusArray;
        
        minusArray = [[NSMutableArray alloc] initWithArray:self.staticAllContacts];
        [minusArray removeObject:member];
        _contactsTableViewController.allContacts = minusArray;
        
        toIndexPath = [NSIndexPath indexPathForRow:[self.entourageMembers indexOfObject:member] inSection:0];
    }
    
    if (!self.isEditing) {
        [[TSJavelinAPIClient sharedClient] removeEntourageMember:member completion:nil];
    }
    
    self.changesMade = YES;
    if (self.shouldMoveCell && !self.animating) {
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
    
    [_contactsTableViewController.tableView reloadData];
    
    self.movingMember = NO;
    self.shouldMoveCell = NO;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return index;
}


- (void)setEntourageMembers:(NSArray *)entourageMembers {
    
    [super setEntourageMembers:entourageMembers];
    
    if (self.filterString) {
        [self setFilterString:self.filterString];
    }
}

- (void)setWhoAddedUser:(NSArray *)whoAddedUser {
    
    [super setWhoAddedUser:whoAddedUser];
    
    if (self.filterString) {
        [self setFilterString:self.filterString];
    }
}

- (void)setAllContacts:(NSArray *)allContacts {
    
    [super setStaticAllContacts:allContacts];
    
    if (self.filterString) {
        [self setFilterString:self.filterString];
    }
}

- (void)setSortedContacts:(NSMutableDictionary *)sortedContacts {
    
    [super setSortedContacts:sortedContacts];
    
    if (self.filterString) {
        [self setFilterString:self.filterString];
    }
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


- (void)setSelectedRowIndex:(NSIndexPath *)selectedRowIndex {
    
    [super setSelectedRowIndex:selectedRowIndex];
    
    if (![_contactsTableViewController.selectedRowIndex isEqual:selectedRowIndex] &&
        (selectedRowIndex || _contactsTableViewController.selectedRowIndex)) {
        _contactsTableViewController.selectedRowIndex = selectedRowIndex;
    }
}

@end
