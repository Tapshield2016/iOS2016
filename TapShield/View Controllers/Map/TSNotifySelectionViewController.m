//
//  TSNotifySelectionViewController.m
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNotifySelectionViewController.h"
#import "TSAddMemberCell.h"

#define INSET 50

static NSString * const kPastUserSelections = @"kPastUserSelections";

@interface TSNotifySelectionViewController ()

@end

@implementation TSNotifySelectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _collectionView.contentInset = UIEdgeInsetsMake(INSET, 0, 0, 0);
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kPastUserSelections];
    NSSet *set = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    _savedContacts = [[NSMutableArray alloc] initWithArray:[set allObjects]];
    _entourageMembers = [[NSMutableSet alloc] initWithSet:set];
    
    self.translucentBackground = YES;
    CGRect frame = self.view.frame;
    frame.origin.y += self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.toolbar.frame = frame;
    
    [self addDescriptionToNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self showContainerView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self hideContainerView];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    
    [super willMoveToParentViewController:parent];
    
    if (!parent) {
        [self transitionNavigationBarAnimatedRight];
        [self whiteNavigationBar];
    }
}

- (void)addDescriptionToNavBar {
    
    _addressLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _routeInfoView.frame.size.width, 21.0f)];
    _addressLabel.text = _addressString;
    _addressLabel.textColor = [TSColorPalette whiteColor];
    _addressLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:13.0f];
    _addressLabel.textAlignment = NSTextAlignmentCenter;
    [_addressLabel setAdjustsFontSizeToFitWidth:YES];
    
    _etaLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, _routeInfoView.frame.size.width, 16.0f)];
    _etaLabel.textColor = [TSColorPalette whiteColor];
    _etaLabel.text = _etaString;
    _etaLabel.font = [TSRalewayFont fontWithName:kFontRalewayLight size:12.0f];
    _etaLabel.textAlignment = NSTextAlignmentCenter;
    [_etaLabel setAdjustsFontSizeToFitWidth:YES];
    
    
    _containerView = [[UIView alloc] initWithFrame:_routeInfoView.frame];
    [_containerView addSubview:_addressLabel];
    [_containerView addSubview:_etaLabel];
    [self.navigationController.navigationBar addSubview:_containerView];
    
    _containerView.alpha = 0.0f;
}

- (void)showContainerView {
    
    [UIView animateWithDuration:0.3f animations:^{
        _containerView.alpha = 1.0f;
    }];
}

- (void)hideContainerView {
    
    [UIView animateWithDuration:0.3f animations:^{
        _containerView.alpha = 0.0f;
    }];
}

#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float cellHeight = 107;
    float offset = scrollView.contentOffset.y + INSET;
    int page = offset/cellHeight;
    offset -= cellHeight * page;
    
    if (offset < 0) {
        return;
    }
    
    NSArray *array = [_collectionView.visibleCells copy];
    for (UICollectionViewCell *cell in array) {
        NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
        
        UICollectionViewCell *cellAtIndex = (UICollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        [self adjustCell:cellAtIndex forOffset:scrollView.contentOffset.y];
    }
}

- (void)addOrRemoveMember:(TSEntourageMemberCell *)memberCell {
    
    if ([_entourageMembers containsObject:memberCell.member]) {
        if (!memberCell.button.selected) {
            [_entourageMembers removeObject:memberCell.member];
        }
    }
    else {
        if (memberCell.button.selected) {
            [_entourageMembers addObject:memberCell.member];
        }
    }
    
    [self archiveUsersPicked];
}

- (void)adjustCell:(UICollectionViewCell *)cell forOffset:(float)offset {
    
    float cellHeight = 107;
    
    offset = offset + INSET;
    int page = offset/cellHeight;
    
    offset -= cellHeight * page;
    float ratio = offset/cellHeight;
    float ratioChange = 1 - ratio;
    
    if (offset < 0) {
        return;
    }
    
    if (cell.frame.origin.y < (page + 1) * cellHeight) {
        cell.alpha = ratioChange;
        cell.transform = CGAffineTransformMakeScale(ratioChange, ratioChange);
    }
    else {
        cell.alpha = 1.0;
        cell.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    
    if (cell.frame.origin.y < page * cellHeight) {
        cell.alpha = 0.0;
    }
}

#pragma mark - Collection View Data Source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
     NSString *cellIdentifier = @"ContactCell";
    
    if (indexPath.item == 0) {
         cellIdentifier = @"AddCell";
        
        TSAddMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell addButtonTarget:self action:@selector(showPeoplePickerNavigationController)];
        
        [self adjustCell:cell forOffset:_collectionView.contentOffset.y];
        
        return cell;
    }

    TSEntourageMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.item <= _savedContacts.count && indexPath.item != 0) {
        cell.member = _savedContacts[indexPath.item - 1];
        [cell addButtonTarget:self action:@selector(addOrRemoveMember:)];
        
        if (![_entourageMembers containsObject:cell.member]) {
            cell.button.selected = NO;
        }
    }
    
    [self adjustCell:cell forOffset:_collectionView.contentOffset.y];
    
    return cell;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (_savedContacts.count < 3) {
        return 3;
    }
    
    return _savedContacts.count + 1;
}



#pragma mark - ABPeoplePickerNavigationControllerDelegate methods

- (void)showPeoplePickerNavigationController {
    
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    if (error) {
        NSLog(@"error");
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
        CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
        
        for( CFIndex index = 0; index < nPeople; index++ ) {
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, index );
            ABMutableMultiValueRef phoneRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
            ABMutableMultiValueRef emailRef = ABRecordCopyValue(person, kABPersonEmailProperty);
            int phoneCount = ABMultiValueGetCount(phoneRef);
            int emailCount = ABMultiValueGetCount(emailRef);
            
            if (!phoneCount && !emailCount) {
                CFErrorRef error = nil;
                ABAddressBookRemoveRecord(addressBook, person, &error);
                if (error) {
                    NSLog(@"Error: %@", error);
                }
            }
            
            CFRelease(phoneRef);
            CFRelease(emailRef);
        }
        
        nPeople = ABAddressBookGetPersonCount( addressBook );
        
        CFRelease(allPeople);
        
        if (nPeople == 0) {
            NSLog(@"No contacts with Phone Numbers or Email");
            CFRelease(addressBook);
            return;
        }
        
        ABAddressBookSave(addressBook, &error);
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
            picker.addressBook = addressBook;
            picker.topViewController.navigationItem.title = @"Contacts";
            picker.peoplePickerDelegate = self;
            picker.displayedProperties = @[@(kABPersonEmailProperty), @(kABPersonPhoneProperty)];
            [self presentViewController:picker animated:YES completion:nil];
            
            CFRelease(addressBook);
        });
    });
    
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    TSJavelinAPIEntourageMember *member = [[TSJavelinAPIEntourageMember alloc] initWithPerson:person property:property identifier:identifier];
    
    [self addEntourageMember:member];
    
    [self archiveUsersPicked];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [_collectionView reloadData];
    
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)archiveUsersPicked {
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_entourageMembers];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kPastUserSelections];
}

- (void)addEntourageMember:(TSJavelinAPIEntourageMember *)member {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        TSJavelinAPIEntourageMember *sortingMember = (TSJavelinAPIEntourageMember *)evaluatedObject;
        if (sortingMember.recordID == member.recordID) {
            return YES;
        }
        return NO;
    }];
    NSArray *filtered = [_savedContacts filteredArrayUsingPredicate:predicate];
    
    [_savedContacts removeObjectsInArray:filtered];
    [_entourageMembers minusSet:[NSSet setWithArray:filtered]];
    
    [_savedContacts insertObject:member atIndex:0];
    [_entourageMembers addObject:member];
}

@end
