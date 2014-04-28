//
//  TSNotifySelectionViewController.h
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSHomeViewController.h"
#import "TSEntourageMemberCell.h"
#import <AddressBookUI/AddressBookUI.h>

#define INSET 50

@interface TSNotifySelectionViewController : TSNavigationViewController <UICollectionViewDataSource, UICollectionViewDelegate, ABPeoplePickerNavigationControllerDelegate, UIScrollViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *routeInfoView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *circleContainerView;

@property (nonatomic, strong) TSHomeViewController *homeViewController;
@property (nonatomic, strong) id keyValueObserver;

@property (assign, nonatomic) NSTimeInterval estimatedTimeInterval;
@property (assign, nonatomic) NSTimeInterval timeAdjusted;

@property (strong, nonatomic) TSBaseLabel *addressLabel;
@property (strong, nonatomic) TSBaseLabel *etaLabel;
@property (strong, nonatomic) TSBaseLabel *timeAdjustLabel;
@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic) NSMutableArray *savedContacts;
@property (strong, nonatomic) NSMutableSet *entourageMembers;

- (void)addOrRemoveMember:(TSEntourageMemberCell *)memberCell;
- (IBAction)startEntourage:(id)sender;


@end
