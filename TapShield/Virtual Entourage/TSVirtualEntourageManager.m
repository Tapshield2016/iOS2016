//
//  TSVirtualEntourageManager.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSVirtualEntourageManager.h"
#import "TSUtilities.h"
#import "TSHomeViewController.h"
#import "MKMapItem+EncodeDecode.h"
#import "TSLocalNotification.h"
#import "NSDate+Utilities.h"

#define WALKING_RADIUS_MIN 25
#define DRIVING_RADIUS_MIN 50

#define ARRIVAL_MESSAGE @"%@ has arrived at %@, %@."
#define NON_ARRIVAL_MESSAGE @"%@ has not made it to %@, %@, within their estimated time of arrival."
#define NON_ARRIVAL_LOCATION @"%@'s latest location %@"
#define NOTIFICATION_TIMES @(60*5), @(60), @(30), @(10), @(5), nil

#define WARNING_TITLE @"WARNING"
#define WARNING_MESSAGE @"Due to iOS software limitations, TapShield is unable to automatically call 911 when the app is running in the background. Authorities will be alerted if you are within your organization's boundaries"

static NSString * const kSpeechRemaining = @"%@ remaining";
static NSString * const kSpeechEntourageNotify = @"Entourage will be notified in 10 seconds, please enter your pass code.";
static NSString * const kLocalNoteEnterPasscode = @"Entourage will be notified in 10 seconds, please enter passcode.";

static NSString * const kGoogleMapsPath = @"http://maps.google.com/maps?q=%f,%f";

static NSString * const TSVirtualEntourageManagerMembersPosted = @"TSVirtualEntourageManagerMembersPosted";
static NSString * const TSVirtualEntourageManagerWarning911 = @"TSVirtualEntourageManagerWarning911";

NSString * const TSVirtualEntourageManagerTimerDidStart = @"TSVirtualEntourageManagerTimerDidStart";
NSString * const TSVirtualEntourageManagerTimerDidEnd = @"TSVirtualEntourageManagerTimerDidEnd";

@interface TSVirtualEntourageManager ()

@property (weak, nonatomic) TSHomeViewController *homeView;
@property (strong, nonatomic) UIAlertView *recalculateAlertView;
@property (strong, nonatomic) UIAlertView *notifyEntourageAlertView;
@property (strong, nonatomic) TSPopUpWindow *warningWindow;
@property (strong, nonatomic) NSTimer *textToSpeechTimer;

@end

@implementation TSVirtualEntourageManager

static TSVirtualEntourageManager *_sharedEntourageManagerInstance = nil;
static dispatch_once_t predicate;

+ (instancetype)initSharedEntourageManagerWithHomeView:(TSHomeViewController *)homeView {
    
    if (_sharedEntourageManagerInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedEntourageManagerInstance = [[self alloc] initWithHomeView:homeView];
        });
    }
    else {
        _sharedEntourageManagerInstance.homeView = homeView;
        _sharedEntourageManagerInstance.routeManager.mapView = homeView.mapView;
    }
    
    return _sharedEntourageManagerInstance;
}

+ (instancetype)sharedManager {
    if (_sharedEntourageManagerInstance == nil) {
        [NSException raise:@"Shared Manager Not Initialized"
                    format:@"Before calling [TSVirtualEntourageManager sharedManager] you must first initialize the shared manager"];
    }
    
    return _sharedEntourageManagerInstance;
}

- (instancetype)initWithHomeView:(TSHomeViewController *)homeView {
    self = [super init];
    if (self) {
        _isEnabled = NO;
        self.homeView = homeView;
        self.routeManager = [[TSRouteManager alloc] initWithMapView:homeView.mapView];
        self.entourageMembersPosted = [TSVirtualEntourageManager unArchiveEntourageMembersPosted];
    }
    return self;
}

- (void)startEntourageWithMembers:(NSSet *)members ETA:(NSTimeInterval)eta completion:(TSVirtualEntourageManagerPostCompletion)completion {
    
    _selectedETA = eta;
    [_homeView entourageModeOn];
    [_routeManager showOnlySelectedRoute];
    
    _endRegions = [self regionsForEndPoint];
    
    __weak typeof(self) weakSelf = self;
    [self addOrRemoveMembers:members completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf resetTimerWithTimeInterval:eta];
            [strongSelf checkRegion:[TSLocationController sharedLocationController].location];
            
            if (completion) {
                completion(finished);
            }
        }
    }];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:TSVirtualEntourageManagerWarning911]) {
        _warningWindow = [[TSPopUpWindow alloc] initWithRepeatCheckBox:TSVirtualEntourageManagerWarning911
                                                                  title:WARNING_TITLE
                                                                message:WARNING_MESSAGE];
        _warningWindow.popUpDelegate = self;
        [_warningWindow show];
    }
}

- (NSArray *)regionsForEndPoint {
    
    float radius;
    if (_routeManager.destinationTransportType == MKDirectionsTransportTypeWalking) {
        radius = WALKING_RADIUS_MIN;
    }
    else {
        radius = DRIVING_RADIUS_MIN;
    }
    
    CLLocationCoordinate2D destinationCoord = _routeManager.destinationAnnotation.coordinate;
    MKMapPoint routeEnd = _routeManager.selectedRoute.route.polyline.points[_routeManager.selectedRoute.route.polyline.pointCount - 1];
    CLLocationCoordinate2D routeEndcoord = MKCoordinateForMapPoint(routeEnd);
    
    CLCircularRegion *destinationRegion = [[CLCircularRegion alloc] initWithCenter:destinationCoord
                                                                           radius:radius
                                                                       identifier:_routeManager.destinationAnnotation.title];
    CLCircularRegion *routeEndRegion = [[CLCircularRegion alloc] initWithCenter:routeEndcoord
                                                                            radius:radius
                                                                        identifier:_routeManager.selectedRoute.route.name];
    
    return @[destinationRegion, routeEndRegion];
}

- (void)checkRegion:(CLLocation *)userLocation  {
    
    BOOL contains = NO;
    
    for (CLCircularRegion *region in [_endRegions copy]) {
        if ([region containsCoordinate:userLocation.coordinate]) {
            contains = YES;
        }
    }
    
    if (userLocation.horizontalAccuracy > 100) {
        if (contains) {
            
            [self performSelector:@selector(arrivedAtDestination) withObject:nil afterDelay:5.0];
        }
    }
    else {
        if (contains) {
            
            [self arrivedAtDestination];
        }
    }
    
    contains = NO;
    CLCircularRegion *bufferCircle;
    
    for (CLCircularRegion *region in [_endRegions copy]) {
        bufferCircle = [[CLCircularRegion alloc] initWithCenter:region.center
                                                         radius:region.radius*2
                                                     identifier:[NSString stringWithFormat:@"%@-bufferCircle", region.identifier]];
        if ([bufferCircle containsCoordinate:userLocation.coordinate]) {
            contains = YES;
        }
    }
    
    if (contains) {
        [self performSelector:@selector(arrivedAtDestination) withObject:nil afterDelay:30.0];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(arrivedAtDestination) object:nil];
    }
}


- (void)arrivedAtDestination {
    
    _endRegions = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(arrivedAtDestination) object:nil];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (!_isEnabled) {
            return;
        }
        
        [_homeView clearEntourageAndResetMap];
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].firstName, [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].lastName];
        NSString *destinationName = _routeManager.destinationMapItem.name;
        NSString *message = [NSString stringWithFormat:ARRIVAL_MESSAGE, fullName, destinationName, [TSUtilities formattedAddressWithoutNameFromMapItem:_routeManager.destinationMapItem]];
        
        [[TSJavelinAPIClient sharedClient] notifyEntourageMembers:message completion:^(id responseObject, NSError *error) {
            
        }];
    }];
}

- (void)failedToArriveAtDestination {
    
    if (!_isEnabled) {
        return;
    }
    
    [_homeView clearEntourageAndResetMap];
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].firstName, [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].lastName];
    NSString *destinationName = _routeManager.destinationMapItem.name;
    NSString *message = [NSString stringWithFormat:NON_ARRIVAL_MESSAGE, fullName, destinationName, [TSUtilities formattedAddressWithoutNameFromMapItem:_routeManager.destinationMapItem]];
    
    NSString *googleLocation;
    CLLocation *location = [TSLocationController sharedLocationController].location;
    if (location) {
        googleLocation = [NSString stringWithFormat:kGoogleMapsPath, location.coordinate.latitude, location.coordinate.longitude];
        googleLocation = [NSString stringWithFormat:NON_ARRIVAL_LOCATION, [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].firstName, googleLocation];
    }
    
    [[TSJavelinAPIClient sharedClient] notifyEntourageMembers:message completion:^(id responseObject, NSError *error) {
        if (googleLocation) {
            [[TSJavelinAPIClient sharedClient] notifyEntourageMembers:googleLocation completion:nil];
        }
    }];
}

- (void)addOrRemoveMembers:(NSSet *)members completion:(TSVirtualEntourageManagerPostCompletion)completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        
        [self findMembersToDelete:_entourageMembersPosted newMembers:members completion:^(BOOL done) {
            
            if (completion) {
                _finishedPosting = completion;
            }
            
            if (members.count) {
                
                [self postEntourageMembers:members];
            }
            else {
                
                [self getAllPreviousMembersFromUserAndDeleteMissing];
            }
        }];
    });
    
}

- (void)manuallyEndTracking {
    
    CLLocationDistance distance = [[TSLocationController sharedLocationController].location distanceFromLocation:_routeManager.destinationMapItem.placemark.location] ;
    if (distance <= 300) {
        _notifyEntourageAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You are %@ from your destination", [TSUtilities formattedStringForDistanceInUSStandard:distance]]
                                                               message:@"Would you like notify entourage members of your arrival?"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Arrived", nil];
        [_notifyEntourageAlertView show];
    }
    else {
        [_homeView clearEntourageAndResetMap];
    }
}

- (void)stopEntourage {
    
    _isEnabled = NO;
    [self resetEndTimer];
    [_routeManager removeRouteOverlaysAndAnnotations];
    [_routeManager removeCurrentDestinationAnnotation];
}

#pragma mark - Timer

- (void)resetTimerWithTimeInterval:(NSTimeInterval)interval {
    
    _isEnabled = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetEndTimer];
        _endTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                     target:self
                                                   selector:@selector(timerEnded)
                                                   userInfo:nil
                                                    repeats:NO];
        [self scheduleLocalNotifications];
        [self setNextTimer];
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSVirtualEntourageManagerTimerDidStart object:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

- (void)timerEnded {
    
    [self resetEndTimer];
    
    [TSLocalNotification say:kSpeechEntourageNotify];
    
    [TSLocalNotification presentLocalNotification:kLocalNoteEnterPasscode];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSVirtualEntourageManagerTimerDidEnd object:@"T"];
}

- (void)resetEndTimer {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [_endTimer invalidate];
    _endTimer = nil;
    
    [self resetSpeechTimer];
}

- (void)recalculateEntourageTimerETA {
    
    _recalculateAlertView = [[UIAlertView alloc] initWithTitle:@"Alert Disarmed"
                                                       message:@"Would you like to continue Entourage?"
                                                      delegate:self
                                             cancelButtonTitle:@"End Route"
                                             otherButtonTitles:@"Update ETA", nil];
    [_recalculateAlertView show];
}

- (void)newMapsETA {
    
    [_routeManager calculateETAForSelectedDestination:^(NSTimeInterval expectedTravelTime) {
        [self resetTimerWithTimeInterval:expectedTravelTime];
    }];
}

- (void)scheduleLocalNotifications {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSArray *times = [NSArray arrayWithObjects:NOTIFICATION_TIMES];
    for (NSNumber *seconds in times) {
        NSString *message = [NSString stringWithFormat:@"%@ remaining to reach %@", [TSUtilities formattedDescriptiveStringForDuration:[seconds integerValue]], _routeManager.destinationMapItem.name];
        [TSLocalNotification presentLocalNotification:message fireDate:[NSDate dateWithTimeInterval:-[seconds integerValue] sinceDate:_endTimer.fireDate]];
    }
}

#pragma mark - Add Remove Members

- (void)findMembersToDelete:(NSSet *)oldMembers newMembers:(NSSet *)newMembers completion:(void(^)(BOOL done))completion {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        TSJavelinAPIEntourageMember *sortingMember = (TSJavelinAPIEntourageMember *)evaluatedObject;
        for (TSJavelinAPIEntourageMember *member in newMembers) {
            if (sortingMember.identifier == member.identifier) {
                return NO;
            }
        }
        
        return YES;
    }];
    
    NSSet *filtered = [oldMembers filteredSetUsingPredicate:predicate];
    [self deleteEntourageMembers:filtered completion:completion];
}

- (void)findMembersToAddWithSavedUrls:(NSSet *)oldMembers newMembers:(NSSet *)newMembers{
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        TSJavelinAPIEntourageMember *sortingMember = (TSJavelinAPIEntourageMember *)evaluatedObject;
        for (TSJavelinAPIEntourageMember *member in oldMembers) {
            if (sortingMember.identifier == member.identifier) {
                return NO;
            }
        }
        sortingMember.url = nil;
        return YES;
    }];
    
    NSSet *filtered = [newMembers filteredSetUsingPredicate:predicate];
    [self postEntourageMembers:filtered];
}

- (void)postedMember:(TSJavelinAPIEntourageMember *)member {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        TSJavelinAPIEntourageMember *sortingMember = (TSJavelinAPIEntourageMember *)evaluatedObject;
        if (sortingMember.identifier == member.identifier) {
            return YES;
        }
        return NO;
    }];
    NSSet *filtered = [_entourageMembersPosted filteredSetUsingPredicate:predicate];
    
    if (filtered.count == 0) {
        [_entourageMembersPosted addObject:member];
    }
    
    [self archiveEntourageMembersPosted];
}

- (void)deletedMember:(TSJavelinAPIEntourageMember *)member {
    
    NSLog(@"deletedMember:%@", member.name);
    [_entourageMembersPosted removeObject:member];
    [self archiveEntourageMembersPosted];
}


- (void)failedToPostMember:(TSJavelinAPIEntourageMember *)member error:(NSError *)error {
    
    NSLog(@"failedToPostMember:%@", member.name);
}

- (void)failedToDeletedMember:(TSJavelinAPIEntourageMember *)member error:(NSError *)error{
    
    NSLog(@"failedToDeleteMember:%@ id:%i error:%@ %i", member.name, member.identifier, error.localizedDescription, error.code);
    
    if (error.code == NSURLErrorBadServerResponse) {
        [self deletedMember:member];
    }
}

#pragma mark Network Requests

- (void)postEntourageMembers:(NSSet *)members {
    
    int i = 1;
    for (TSJavelinAPIEntourageMember *member in members) {
        
        [[TSJavelinAPIClient sharedClient] addEntourageMember:member completion:^(id responseObject, NSError *error) {
            if (!error) {
                [self postedMember:member];
            }
            else {
                [self failedToPostMember:member error:error];
            }
            
            if (i == members.count) {
                [self getAllPreviousMembersFromUserAndDeleteMissing];
            }
        }];
        i++;
    }
}

- (void)deleteEntourageMembers:(NSSet *)members completion:(void(^)(BOOL done))completion {
    
    if (!members.count) {
        if (completion) {
            completion(YES);
        }
    }
    
    int i = 1;
    for (TSJavelinAPIEntourageMember *member in members) {
        [[TSJavelinAPIClient sharedClient] removeEntourageMember:member completion:^(id responseObject, NSError *error) {
            if (!error) {
                [self deletedMember:member];
            }
            else {
                [self failedToDeletedMember:member error:error];
            }
            
            if (i == members.count) {
                
                if (completion) {
                    completion(YES);
                }
            }
        }];
        i++;
    }
}

- (void)getAllPreviousMembersFromUserAndDeleteMissing {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] getLoggedInUser:^(TSJavelinAPIUser *user) {
        [self findMembersToDelete:[NSSet setWithArray:user.entourageMembers] newMembers:_entourageMembersPosted completion:^(BOOL done) {
            
            if (_finishedPosting) {
                _finishedPosting(YES);
                _finishedPosting = nil;
            }
            
            [self getAllPostedMembersFromUserAndAddMissing:^(BOOL finished) {
                
            }];
        }];
    }];
}

- (void)getAllPostedMembersFromUserAndAddMissing:(void(^)(BOOL finished))completion {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] getLoggedInUser:^(TSJavelinAPIUser *user) {
        [self findMembersToAddWithSavedUrls:[NSSet setWithArray:user.entourageMembers] newMembers:_entourageMembersPosted];
    }];
}

#pragma mark Archive Members

- (void)archiveEntourageMembersPosted {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_entourageMembersPosted];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:TSVirtualEntourageManagerMembersPosted];
    [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

+ (NSMutableSet *)unArchiveEntourageMembersPosted {
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:TSVirtualEntourageManagerMembersPosted];
    return [[NSMutableSet alloc] initWithSet:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == _recalculateAlertView) {
        if (buttonIndex == 0) {
             [self.homeView clearEntourageAndResetMap];
        }
        else if (buttonIndex == 1) {
            [self newMapsETA];
        }
    }
    if (alertView == _notifyEntourageAlertView) {
        if (buttonIndex == 1) {
            [self arrivedAtDestination];
        }
        else {
            [_homeView clearEntourageAndResetMap];
        }
    }
}

#pragma mark - Pop Up Window Delegate

- (void)didDismissWindow:(UIWindow *)window {
    
    if (window == _warningWindow) {
        _warningWindow = nil;
    }
}


#pragma mark Home View

- (void)removeHomeViewController {
    
    [TSVirtualEntourageManager initSharedEntourageManagerWithHomeView:nil];
}

#pragma mark - Text To Speech

- (void)saySecondsRemaining:(NSTimeInterval)seconds {
    
//    NSString *destination = _routeManager.destinationMapItem.name;
//    if (!destination) {
//        destination = @"destination";
//    }
    NSString *message = [NSString stringWithFormat:kSpeechRemaining, [TSUtilities formattedDescriptiveStringForDuration:seconds]];
//    [NSString stringWithFormat:@"%@ remaining to reach %@", [TSUtilities formattedDescriptiveStringForDuration:seconds], destination];
    [TSLocalNotification say:message];
    
}

#pragma mark - Timer

- (void)setNextTimer {
    
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) {
        // Do some error handling
    }
    [session setActive:YES error:&error];
    if (error) {
        // Do some error handling
    }
    
    NSArray *times = [NSArray arrayWithObjects:NOTIFICATION_TIMES];
    for (NSNumber *time in times) {
        if ([[_endTimer.fireDate dateByAddingTimeInterval:-time.integerValue] timeIntervalSinceNow] > 1) {
            [self speechTimerWithTimeInterval:[_endTimer.fireDate dateByAddingTimeInterval:-time.integerValue]];
            return;
        }
    }
}

- (void)speechTimerWithTimeInterval:(NSDate *)date {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetSpeechTimer];
        
        _textToSpeechTimer = [NSTimer scheduledTimerWithTimeInterval:[date timeIntervalSinceNow]-1
                                                     target:self
                                                   selector:@selector(sayTimerTarget:)
                                                   userInfo:nil
                                                    repeats:NO];
        [_textToSpeechTimer setFireDate:date];
    });
}

- (void)sayTimerTarget:(NSTimer *)timer {
    
    [self resetSpeechTimer];
    
    [self saySecondsRemaining:[_endTimer.fireDate timeIntervalSinceDate:[NSDate date]]];
    
    [self setNextTimer];
}

- (void)resetSpeechTimer {
    
    [_textToSpeechTimer invalidate];
    _textToSpeechTimer = nil;
}

@end
