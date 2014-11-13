//
//  TSBaseEntourageContactsTableViewController.h
//  TapShield
//
//  Created by Adam Share on 11/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNavigationViewController.h"
#define kContactsSectionOffset 3

@interface TSBaseEntourageContactsTableViewController : UITableViewController

@property (assign, nonatomic) BOOL isResultsController;

@property (strong, nonatomic) NSArray *allContacts;
@property (strong, nonatomic) NSArray *entourageMembers;
@property (strong, nonatomic) NSArray *whoAddedUser;

@property (strong, nonatomic) NSArray *staticAllContacts;
@property (strong, nonatomic) NSArray *staticEntourageMembers;
@property (strong, nonatomic) NSArray *staticWhoAddedUser;


@property (strong, nonatomic) NSMutableDictionary *sortedContacts;

@property (strong, nonatomic) NSMutableDictionary *staticSortedContacts;


@property (strong, nonatomic) UISearchController *searchController;

@property (assign, nonatomic) BOOL isEditing;

@property (assign, nonatomic, getter=isSyncing) BOOL syncing;
@property (assign, nonatomic) BOOL changesMade;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (assign, nonatomic) BOOL searching;
@property (assign, nonatomic) BOOL animating;
@property (assign, nonatomic) BOOL shouldReload;
@property (assign, nonatomic) BOOL movingMember;

@property (strong ,nonatomic) NSIndexPath *selectedRowIndex;

@property (strong, nonatomic) UIButton *editButton;

@property (strong, nonatomic) NSString *filterString;


@property (strong, nonatomic) TSJavelinAPIEntourageMember *selectedMember;


- (void)setContactList:(NSArray *)contacts;


- (NSMutableDictionary *)sortContacts:(NSArray *)contacts;
- (NSArray *)sortedMemberArray:(NSArray *)array;
- (NSArray *)sortedKeyArray:(NSArray *)array;
- (BOOL)sectionExistsForMember:(TSJavelinAPIEntourageMember *)member;

- (void)updateEditingButton;

- (TSJavelinAPIEntourageMember *)memberForIndexPath:(NSIndexPath *)indexPath;
- (void)toggleSelectedIndexPath:(NSIndexPath *)indexPath;
- (void)setIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;
- (NSIndexPath *)indexPathOfSortedContact:(TSJavelinAPIEntourageMember *)member;

- (void)syncEntourageMembers;

- (void)presentMemberSettingsWithMember:(TSJavelinAPIEntourageMember *)member;

- (void)editEntourageMembers;

- (void)animatePane:(BOOL)openWide;

@end
