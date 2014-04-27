//
//  TSNotifySelectionViewController.m
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNotifySelectionViewController.h"
#import "TSAddMemberCell.h"
#import "TSCircularControl.h"

#define INSET 50

static NSString * const kRecentSelections = @"kRecentSelections";

@interface TSNotifySelectionViewController ()

@property (strong, nonatomic) NSTimer *clockTimer;
@property (strong, nonatomic) UIAlertView *saveChangesAlertView;
@property (assign, nonatomic) BOOL changedTime;
@property (strong, nonatomic) TSCircularControl *slider;

@end

@implementation TSNotifySelectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _collectionView.contentInset = UIEdgeInsetsMake(INSET, 0, 20.0, 0);
    
    _changedTime = NO;
    
    NSSet *set = [TSVirtualEntourageManager unArchiveEntourageMembersPosted];
    _savedContacts = [[NSMutableArray alloc] initWithArray:[set allObjects]];
    _entourageMembers = [[NSMutableSet alloc] initWithSet:set];
    [self mergeRecentPicksWithCurrentMembers];
    
    self.translucentBackground = YES;
    CGRect frame = self.view.frame;
    frame.origin.y += self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.toolbar.frame = frame;
    
    [self addDescriptionToNavBar];
    //Create the Circular Slider
    _slider = [[TSCircularControl alloc]initWithFrame:_circleContainerView.frame];
//    slider.center = CGPointMake(self.view.center.x, self.view.center.y/1.5);
    
    _estimatedTimeInterval = _homeViewController.entourageManager.routeManager.selectedRoute.route.expectedTravelTime;
    _timeAdjusted = _estimatedTimeInterval;
    _timeAdjustLabel = [[TSBaseLabel alloc] initWithFrame:_slider.frame];
    _timeAdjustLabel.text = [TSUtilities formattedStringForTime:_estimatedTimeInterval];
    _timeAdjustLabel.font = [TSRalewayFont fontWithName:kFontRalewayLight size:25.0];
    _timeAdjustLabel.textAlignment = NSTextAlignmentCenter;
    _timeAdjustLabel.textColor = [UIColor whiteColor];
    
    //Define Target-Action behaviour
    [_slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_slider];
    [self.view addSubview:_timeAdjustLabel];
    
    if (_homeViewController.entourageManager.isEnabled) {
        [self blackNavigationBar];
        self.removeNavigationShadow = YES;
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneEditingEntourage)];
        [barButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [TSColorPalette whiteColor],
                                            NSFontAttributeName :[TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f]} forState:UIControlStateNormal];
        [self.navigationItem setRightBarButtonItem:barButton];
        
        [self adjustViewableTime];
    }
    
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

- (void)dismissViewController {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (_keyValueObserver) {
            [_homeViewController.entourageManager.routeManager removeObserver:_keyValueObserver
                                                                   forKeyPath:@"selectedRoute"
                                                                      context: NULL];
        }
        [_homeViewController viewWillAppear:NO];
        [_homeViewController viewDidAppear:NO];
    }];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    
    [super willMoveToParentViewController:parent];
    
    if (!parent) {
        [self transitionNavigationBarAnimatedRight];
        [self whiteNavigationBar];
    }
}

- (void)addDescriptionToNavBar {
    
    NSString *formattedText = [NSString stringWithFormat:@"%@ - %@", [TSUtilities formattedDescriptiveStringForDuration:_homeViewController.entourageManager.routeManager.selectedRoute.route.expectedTravelTime], [TSUtilities fromattedStringForDistanceInUSStandard:_homeViewController.entourageManager.routeManager.selectedRoute.route.distance]];
    
    _addressLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _routeInfoView.frame.size.width, 21.0f)];
    _addressLabel.text = _homeViewController.entourageManager.routeManager.selectedRoute.route.name;
    _addressLabel.textColor = [TSColorPalette whiteColor];
    _addressLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:13.0f];
    _addressLabel.textAlignment = NSTextAlignmentCenter;
    [_addressLabel setAdjustsFontSizeToFitWidth:YES];
    
    _etaLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, _routeInfoView.frame.size.width, 16.0f)];
    _etaLabel.textColor = [TSColorPalette whiteColor];
    _etaLabel.text = formattedText;
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

#pragma mark - Circular Control 

/** This function is called when Circular slider value changes **/
- (void)newValue:(TSCircularControl *)slider {
    
    [self stopClockTimer];
    
    int adjustedAngle;
    if (slider.angle <= 90) {
        adjustedAngle = 90 - slider.angle;
    }
    else {
        adjustedAngle = 360 - slider.angle + 90;
    }
    
    NSTimeInterval addedTime = (int)adjustedAngle - 180;
    float timeRatio = _estimatedTimeInterval/180;
    
    addedTime = _estimatedTimeInterval + addedTime * timeRatio;
    _timeAdjustLabel.text = [TSUtilities formattedStringForTime:addedTime];
    _timeAdjusted = (int)addedTime;
    
    _changedTime = YES;
}

- (void)adjustViewableTime {
    
    NSTimeInterval interval = 1;
    if (_estimatedTimeInterval < 320) {
        interval = .1;
    }
    
    if (!_clockTimer) {
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                       target:self
                                                     selector:@selector(adjustViewableTime)
                                                     userInfo:nil
                                                      repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_clockTimer forMode:NSRunLoopCommonModes];
    }
    
    NSDate *fireDate = _homeViewController.entourageManager.endTimer.fireDate;
    
    _timeAdjusted = [fireDate timeIntervalSinceDate:[NSDate date]];
    _timeAdjustLabel.text = [TSUtilities formattedStringForTime:_timeAdjusted];
    
    [_slider setDegreeForStartTime:_estimatedTimeInterval currentTime:_timeAdjusted];
}

- (void)stopClockTimer {
    
    [_clockTimer invalidate];
    _clockTimer = nil;
}

#pragma mark - Scroll View Delegate

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

- (void)adjustCell:(UICollectionViewCell *)cell forOffset:(float)offset {
    
    float cellHeight = 107;
    
    offset = offset + INSET;
    int page = offset/cellHeight;
    
    offset -= cellHeight * page;
    float ratio = offset/cellHeight;
    float ratioChange = 1 - ratio;
    float acceleratedAlpha = 1 - (ratio * 1.5);
    
    if (offset < 0) {
        return;
    }
    
    if (cell.frame.origin.y < (page + 1) * cellHeight) {
        cell.alpha = acceleratedAlpha;
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


#pragma mark - Entourage

- (IBAction)startEntourage:(id)sender {
    
    [_homeViewController.entourageManager startEntourageWithMembers:_entourageMembers ETA:_timeAdjusted];
    
    [self dismissViewController];
}

- (void)doneEditingEntourage {
    
    if ([self changesWereMade]) {
        _saveChangesAlertView = [[UIAlertView alloc] initWithTitle:@"Enter passcode to confirm changes" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        _saveChangesAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [_saveChangesAlertView textFieldAtIndex:0];
        [textField setPlaceholder:@"1234"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setSecureTextEntry:YES];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [textField setDelegate:self];
        
        [_saveChangesAlertView show];
    }
    else {
        [self dismissViewController];
    }
}

- (BOOL)changesWereMade {
    
    if (_entourageMembers.count != _homeViewController.entourageManager.entourageMembersPosted.count) {
        return YES;
    }
    
    if (_entourageMembers) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            TSJavelinAPIEntourageMember *sortingMember = (TSJavelinAPIEntourageMember *)evaluatedObject;
            
            if (!sortingMember.identifier) {
                return YES;
            }
            
            for (TSJavelinAPIEntourageMember *member in [_homeViewController.entourageManager.entourageMembersPosted copy]) {
                if (sortingMember.identifier == member.identifier) {
                    return NO;
                }
            }
            
            return YES;
        }];
        
        NSSet *filtered = [_entourageMembers filteredSetUsingPredicate:predicate];
        
        if (filtered.count) {
            NSLog(@"changed users");
            return YES;
        }
    }
    
    
    
    return _changedTime;
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
    
}

- (void)archiveUsersPicked {
    
    NSArray *array = _savedContacts;
    if (_savedContacts.count > 11) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 11)];
        array = [_savedContacts objectsAtIndexes:indexSet];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kRecentSelections];
}

+ (NSArray *)unarchiveRecentPicks {
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentSelections];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)mergeRecentPicksWithCurrentMembers {
    
    NSArray *recentPicks = [TSNotifySelectionViewController unarchiveRecentPicks];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        TSJavelinAPIEntourageMember *sortingMember = (TSJavelinAPIEntourageMember *)evaluatedObject;
        
        for (TSJavelinAPIEntourageMember *member in [_savedContacts copy]) {
            if (sortingMember.recordID == member.recordID) {
                return NO;
            }
        }
        
        return YES;
    }];
    
    NSArray *filtered = [recentPicks filteredArrayUsingPredicate:predicate];
    [_savedContacts addObjectsFromArray:filtered];
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



#pragma mark - ABPeoplePickerNavigationControllerDelegate methods

- (void)setNavigationBarStyle:(UIViewController *)picker {
    
    picker.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    picker.navigationController.navigationBar.tintColor = [TSColorPalette tapshieldBlue];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [UINavigationBar appearance].tintColor = [TSColorPalette tapshieldBlue];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontRalewayMedium size:17.0f] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.3] , NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateDisabled];
    
    [picker.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [picker.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    picker.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontRalewayMedium size:17.0f] };
}

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
            [self setNavigationBarStyle:picker];
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
    
    [self blackNavigationBar];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [_collectionView reloadData];
    
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    
    [self blackNavigationBar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Alert View Delegate 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self dismissViewController];
    }
    if (buttonIndex == 1) {
        [self performSelector:@selector(startEntourage:) withObject:nil];
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    textField.backgroundColor = [TSColorPalette whiteColor];
    
    if ([textField.text length] + [string length] - range.length == 4) {
        textField.text = [textField.text stringByAppendingString:string];
        [self checkDisarmCode:textField];
        return NO;
    }
    else if ([textField.text length] + [string length] - range.length > 4) {
        [self checkDisarmCode:textField];
        return NO;
    }
    
    return YES;
}

- (void)checkDisarmCode:(UITextField *)textField {
    
    if (textField.text.length != 4) {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
        return;
    }
    
    if ([textField.text isEqualToString:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode]) {
        [_saveChangesAlertView dismissWithClickedButtonIndex:1 animated:YES];
    }
    else {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
    }
}


- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [super dismissViewControllerAnimated:flag completion:completion];
    
    if (_saveChangesAlertView) {
        [_saveChangesAlertView dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

@end
