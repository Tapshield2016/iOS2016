//
//  TSEntourageContactSearchResultsTableViewController.h
//  TapShield
//
//  Created by Adam Share on 10/31/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSEntourageContactsTableViewController.h"

@interface TSEntourageContactSearchResultsTableViewController : UITableViewController

@property (strong, nonatomic) NSString *filterString;

@property (strong, nonatomic) NSArray *staticAllContacts;
@property (strong, nonatomic) NSArray *staticEntourageMembers;
@property (strong, nonatomic) NSArray *staticWhoAddedUser;

@property (strong, nonatomic) NSMutableDictionary *staticSortedContacts;

@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL syncing;

@property (weak, nonatomic) TSEntourageContactsTableViewController *contactsTableViewController;

- (void)updateEditingButton;

@end
