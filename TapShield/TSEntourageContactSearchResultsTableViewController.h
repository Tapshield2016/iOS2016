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

@property (strong, nonatomic) NSArray *allContacts;
@property (strong, nonatomic) NSArray *entourageMembers;
@property (strong, nonatomic) NSArray *whoAddedUser;

@property (strong, nonatomic) NSMutableDictionary *sortedContacts;

@property (weak, nonatomic) TSEntourageContactsTableViewController *contactsTableViewController;

- (void)updateEditingButton:(BOOL)editing;

@end
