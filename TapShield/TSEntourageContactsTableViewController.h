//
//  TSEntourageContactsTableViewController.h
//  TapShield
//
//  Created by Adam Share on 10/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kContactsSectionOffset 3

@interface TSEntourageContactsTableViewController : UITableViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) NSArray *allContacts;
@property (strong, nonatomic) NSArray *entourageMembers;
@property (strong, nonatomic) NSArray *whoAddedUser;

@property (strong, nonatomic) NSMutableDictionary *sortedContacts;

@property (strong, nonatomic) UISearchController *searchController;

@property (assign, nonatomic) BOOL isEditing;

@property (assign, nonatomic, getter=isSyncing) BOOL syncing;
@property (assign, nonatomic) BOOL changesMade;

- (void)editEntourageMembers;

@end
