//
//  TSEntourageContactsTableViewController.h
//  TapShield
//
//  Created by Adam Share on 10/26/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseEntourageContactsTableViewController.h"

//#define kContactsSectionOffset 3

@interface TSEntourageContactsTableViewController : TSBaseEntourageContactsTableViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

- (void)editEntourageMembers;

@end
