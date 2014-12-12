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
#import "TSMemberCollectionViewLayout.h"
#import <LocalAuthentication/LocalAuthentication.h>


#define TUTORIAL_TITLE @"Set ETA, add your Entourage"
#define TUTORIAL_MESSAGE @"Contacts with a check mark will be notified of your arrival or non-arrival. If you're on-campus and you don't arrive at your destination, we'll also notify campus police."

#define WARNING_TITLE @"WARNING"
#define WARNING_MESSAGE @"Due to iOS software limitations, TapShield is unable to automatically call 911 when the app is running in the background. Authorities will be alerted if you are within your organization's boundaries"

static NSString * const TSNotifySelectionViewControllerTutorialShow = @"TSNotifySelectionViewControllerTutorialShow";
static NSString * const TSNotifySelectionViewController911WarningShow = @"TSNotifySelectionViewController911WarningShow";
static NSString * const kRecentSelections = @"kRecentSelections";

@interface TSNotifySelectionViewController ()

@property (strong, nonatomic) NSTimer *clockTimer;
@property (strong, nonatomic) UIAlertController *saveChangesAlertController;
@property (assign, nonatomic) BOOL changedTime;
@property (strong, nonatomic) TSCircularControl *slider;
@property (strong, nonatomic) TSMemberCollectionViewLayout *collectionLayout;
@property (strong, nonatomic) TSPopUpWindow *tutorialWindow;
@property (assign, nonatomic) BOOL isStarting;

@end

@implementation TSNotifySelectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _changedTime = NO;
    _isStarting = NO;
    
    _collectionLayout = [[TSMemberCollectionViewLayout alloc] init];
    _collectionView.contentInset = UIEdgeInsetsMake(INSET, 0, 20.0, 0);
    [_collectionView setCollectionViewLayout:_collectionLayout];
    
    NSSet *set = [NSSet setWithArray:[TSJavelinAPIClient loggedInUser].entourageMembers.allValues];
    _savedContacts = [[NSMutableArray alloc] initWithArray:[self alphabeticalMembers:[set allObjects]]];
    _entourageMembers = [[NSMutableSet alloc] initWithSet:set];
    [self mergeRecentPicksWithCurrentMembers];
    
    self.translucentBackground = YES;
    
    [self addDescriptionToNavBar];
    //Create the Circular Slider
    _slider = [[TSCircularControl alloc]initWithFrame:_circleContainerView.frame];
//    slider.center = CGPointMake(self.view.center.x, self.view.center.y/1.5);
    
    _estimatedTimeInterval = [TSEntourageSessionManager sharedManager].routeManager.selectedRoute.expectedTravelTime;
    
    _timeAdjusted = _estimatedTimeInterval;
    _timeAdjustLabel = [[TSBaseLabel alloc] initWithFrame:_slider.frame];
    _timeAdjustLabel.text = [TSUtilities formattedStringForTime:_estimatedTimeInterval];
    _timeAdjustLabel.font = [TSFont fontWithName:kFontWeightThin size:30.0];
    _timeAdjustLabel.textAlignment = NSTextAlignmentCenter;
    _timeAdjustLabel.textColor = [UIColor whiteColor];
    
    //Define Target-Action behaviour
    [_slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_slider];
    [self.view addSubview:_timeAdjustLabel];
    
    if ([TSEntourageSessionManager sharedManager].isEnabled) {
        [self blackNavigationBar];
        self.removeNavigationShadow = YES;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneEditingEntourage)];
        [doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [TSColorPalette whiteColor],
                                            NSFontAttributeName :[TSFont fontWithName:kFontWeightLight size:17.0f]} forState:UIControlStateNormal];
        [self.navigationItem setRightBarButtonItem:doneButton];
        
        [self adjustViewableTime];
    }
    
    [self showTutorial];
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

- (void)showTutorial {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:TSNotifySelectionViewControllerTutorialShow]) {
        return;
    }
    
    _tutorialWindow = [[TSPopUpWindow alloc] initWithRepeatCheckBox:TSNotifySelectionViewControllerTutorialShow
                                                              title:TUTORIAL_TITLE
                                                            message:TUTORIAL_MESSAGE];
    [_tutorialWindow show];
}

- (void)dismissViewController {
    
    UINavigationController *navcontroller = (UINavigationController *)[[UIApplication sharedApplication].delegate.window.rootViewController.childViewControllers firstObject];
    [[navcontroller.childViewControllers lastObject] beginAppearanceTransition:YES animated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[navcontroller.childViewControllers lastObject] endAppearanceTransition];
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
    
    NSTimeInterval travelTime = [TSEntourageSessionManager sharedManager].routeManager.selectedRoute.expectedTravelTime;
    
    CLLocationDistance distance = [TSEntourageSessionManager sharedManager].routeManager.selectedRoute.distance;
    
    NSString *formattedText = [NSString stringWithFormat:@"%@ - %@", [TSUtilities formattedDescriptiveStringForDuration:travelTime], [TSUtilities formattedStringForDistanceInUSStandard:distance]];
    
    _addressLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _routeInfoView.frame.size.width, 21.0f)];
    _addressLabel.text = [TSEntourageSessionManager sharedManager].routeManager.selectedRoute.name;
    _addressLabel.textColor = [TSColorPalette whiteColor];
    _addressLabel.font = [TSFont fontWithName:kFontWeightLight size:13.0f];
    _addressLabel.textAlignment = NSTextAlignmentCenter;
    [_addressLabel setAdjustsFontSizeToFitWidth:YES];
    
    _etaLabel = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, _routeInfoView.frame.size.width, 16.0f)];
    _etaLabel.textColor = [TSColorPalette whiteColor];
    _etaLabel.text = formattedText;
    _etaLabel.font = [TSFont fontWithName:kFontWeightLight size:12.0f];
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
    
    NSDate *fireDate = [TSEntourageSessionManager sharedManager].endTimer.fireDate;
    
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
        cell.alpha = 1.0;
        cell.transform = CGAffineTransformMakeScale(1.0, 1.0);
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


- (void)shimmerCollectionView {
    
    [UIView animateWithDuration:0.1 animations:^{
        [_collectionView setContentOffset:CGPointMake(0, -INSET)];
    } completion:^(BOOL finished) {
        CGRect frame = _collectionView.frame;
        frame.origin.y += INSET;
        FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:frame];
        shimmeringView.contentView = _collectionView;
        
        frame.origin.y = 0;
        _collectionView.frame = frame;
        [_collectionView setContentOffset:CGPointMake(0, -INSET) animated:NO];
        [self scrollViewDidScroll:_collectionView];
        
        [self.view addSubview:shimmeringView];
        shimmeringView.shimmering = YES;
    }];
}

#pragma mark - Entourage

- (IBAction)startEntourage:(id)sender {
    if (_isStarting) {
        return;
    }
    _isStarting = YES;
    [_containerView setUserInteractionEnabled:NO];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self shimmerCollectionView];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [[TSEntourageSessionManager sharedManager] startTrackingWithETA:_timeAdjusted completion:^(BOOL finished) {
        [self dismissViewController];
    }];
}

- (void)didDismissWindow:(UIWindow *)window {
    
    [self dismissViewController];
}

- (void)doneEditingEntourage {
    
    
    if ([self changesWereMade]) {
        
        UIAlertController *askSaveAlertController = [UIAlertController alertControllerWithTitle:@"Changes were made"
                                                                                        message:@"Would you like to save?"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        [askSaveAlertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self dismissViewController];
        }]];
        [askSaveAlertController addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([self touchIDAvailable]) {
                [self useTouchID];
            }
            else {
                [self saveWithPasscode];
            }
        }]];
        [self presentViewController:askSaveAlertController animated:YES completion:nil];
    }
    else {
        [self dismissViewController];
        [[TSEntourageSessionManager sharedManager] startStatusBarTimer];
    }
}


- (void)saveWithPasscode {
    
    _saveChangesAlertController = [UIAlertController alertControllerWithTitle:@"Confirm Changes"
                                                                      message:@"Please enter passcode"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self)weakSelf = self;
    [_saveChangesAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"1234"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setSecureTextEntry:YES];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [textField setDelegate:weakSelf];
    }];
    [_saveChangesAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:_saveChangesAlertController animated:YES completion:nil];
}

- (BOOL)changesWereMade {
    
    if (_entourageMembers.count != [TSJavelinAPIClient loggedInUser].entourageMembers.allValues.count) {
        return YES;
    }
    
    if (_entourageMembers) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            TSJavelinAPIEntourageMember *sortingMember = (TSJavelinAPIEntourageMember *)evaluatedObject;
            
            if (!sortingMember.identifier) {
                return YES;
            }
            
            if ([[TSJavelinAPIClient loggedInUser].entourageMembers objectForKey:sortingMember.url]) {
                return NO;
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
            [self reorderSavedUsersMovingCell:memberCell];
        }
    }
    else {
        if (memberCell.button.selected) {
            [_entourageMembers addObject:memberCell.member];
            [self reorderSavedUsersMovingCell:memberCell];
        }
    }
    
}

- (void)reorderSavedUsersMovingCell:(TSEntourageMemberCell *)cell {
    NSIndexPath *from = [_collectionView indexPathForCell:cell];
    
    [self reorderSavedUsers];
    
    NSIndexPath *to = [NSIndexPath indexPathForItem:[_savedContacts indexOfObject:cell.member]+1 inSection:0];
    
    [_collectionView performBatchUpdates:^{
        [_collectionView moveItemAtIndexPath:from toIndexPath:to];
         } completion:^(BOOL finished) {
             [_collectionView reloadData];
         }];
}

- (void)reorderSavedUsers {
    
    [_savedContacts removeObjectsInArray:[_entourageMembers allObjects]];
    _savedContacts = [[NSMutableArray alloc] initWithArray:[self alphabeticalMembers:_savedContacts]];
    [_savedContacts insertObjects:[self alphabeticalMembers:[_entourageMembers allObjects]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _entourageMembers.count)]];
}

- (void)archiveUsersPicked {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSArray *array = _savedContacts;
        if (_savedContacts.count > 11) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 11)];
            array = [_savedContacts objectsAtIndexes:indexSet];
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kRecentSelections];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
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
        
        sortingMember.url = nil;
        
        return YES;
    }];
    
    
    NSArray *filtered = [recentPicks filteredArrayUsingPredicate:predicate];
    filtered = [self alphabeticalMembers:filtered];
    [_savedContacts addObjectsFromArray:filtered];
}

- (NSArray *)alphabeticalMembers:(NSArray *)rawArray {
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    return [rawArray sortedArrayUsingDescriptors:@[sorter]];
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
    
    [self whiteNavigationBar];
    
    [picker.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [picker.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[TSColorPalette tapshieldBlue], NSForegroundColorAttributeName, [TSFont fontWithName:kFontWeightLight size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    picker.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [TSColorPalette tapshieldBlue], NSFontAttributeName : [UIFont fontWithName:kFontWeightNormal size:17.0f] };
}

- (void)showPeoplePickerNavigationController {
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.predicateForEnablingPerson = [NSPredicate predicateWithFormat:@"phoneNumbers.@count > 0 OR emailAddresses.@count > 0"];
    picker.topViewController.navigationItem.title = @"Contacts";
    picker.navigationBar.topItem.prompt = @"Select an email or SMS capable phone number";
    picker.peoplePickerDelegate = self;
    picker.displayedProperties = @[@(kABPersonEmailProperty), @(kABPersonPhoneProperty)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self presentViewController:picker animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        }];
    });
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    
    [self blackNavigationBar];
    TSJavelinAPIEntourageMember *member = [[TSJavelinAPIEntourageMember alloc] initWithPerson:person];
    [self addEntourageMember:member];
    [self reorderSavedUsers];
    [_collectionView reloadData];
    [self archiveUsersPicked];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    [self blackNavigationBar];
    TSJavelinAPIEntourageMember *member = [[TSJavelinAPIEntourageMember alloc] initWithPerson:person];
    [self addEntourageMember:member];
    [self reorderSavedUsers];
    [_collectionView reloadData];
    [self archiveUsersPicked];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    
    [self blackNavigationBar];
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
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
        [_saveChangesAlertController dismissViewControllerAnimated:YES completion:nil];
        [self performSelector:@selector(startEntourage:) withObject:nil];
    }
    else {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
    }
}

#pragma mark - Syncing Window

- (UIWindow *)showSyncingWindow {
    
    CGRect frame = CGRectMake(0.0f, 0.0f, 260, 100);
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    window.alpha = 0.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.center = window.center;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    
    UIVisualEffectView *toolbar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    toolbar.frame = frame;
    [view addSubview:toolbar];
    
    UIActivityIndicatorView *indicatoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicatoryView startAnimating];
    indicatoryView.center = CGPointMake(frame.size.width/2, frame.size.height*.75 - 5);
    [view addSubview:indicatoryView];
    
    float inset = 10;
    TSBaseLabel *windowMessage = [[TSBaseLabel alloc] initWithFrame:CGRectMake(inset, 0, frame.size.width - inset*2, frame.size.height/2)];
    windowMessage.numberOfLines = 0;
    windowMessage.backgroundColor = [UIColor clearColor];
    windowMessage.text = @"Syncing entourage members to be notified";
    windowMessage.font = [TSFont fontWithName:kFontWeightLight size:17.0f];
    windowMessage.textColor = [UIColor whiteColor];
    windowMessage.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:windowMessage];
    
    [window addSubview:view];
    [window makeKeyAndVisible];
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:300.0
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        window.alpha = 1.0f;
        view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:nil];
    
    return window;
}

- (void)hideWindow:(UIWindow *)window {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            window.alpha = 0.0f;
        } completion:nil];
    });
}


#pragma mark - Touch ID

- (void)useTouchID {
    
    LAContext *context = [[LAContext alloc] init];
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:@"Confirm Changes"
                      reply:^(BOOL success, NSError *error) {
                          
                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                              if (error) {
                                  
                                  if (error.code == kLAErrorUserCancel ||
                                      error.code == kLAErrorSystemCancel) {
                                      
                                  }
                                  else if (error.code == kLAErrorUserFallback) {
                                      [self saveWithPasscode];
                                  }
                                  else {
                                      UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                                      [errorController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                                      [self presentViewController:errorController animated:YES completion:nil];
                                  }
                              }
                              else if (success) {
                                  [_saveChangesAlertController dismissViewControllerAnimated:YES completion:nil];
                                  [self performSelector:@selector(startEntourage:) withObject:nil];
                              }
                          }];
                      }];
}

- (BOOL)touchIDAvailable {
    
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

@end
