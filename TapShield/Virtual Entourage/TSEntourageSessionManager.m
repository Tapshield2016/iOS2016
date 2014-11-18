//
//  TSEntourageSessionManager.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageSessionManager.h"
#import "TSUtilities.h"
#import "TSHomeViewController.h"
#import "MKMapItem+EncodeDecode.h"
#import "TSLocalNotification.h"
#import "NSDate+Utilities.h"
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import "TSStartAnnotation.h"

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

static NSString * const TSEntourageSessionManagerMembersPosted = @"TSEntourageSessionManagerMembersPosted";
static NSString * const TSEntourageSessionManagerWarning911 = @"TSEntourageSessionManagerWarning911";

NSString * const TSEntourageSessionManagerTimerDidStart = @"TSEntourageSessionManagerTimerDidStart";
NSString * const TSEntourageSessionManagerTimerDidEnd = @"TSEntourageSessionManagerTimerDidEnd";

@interface TSEntourageSessionManager ()

@property (strong, nonatomic) TSPopUpWindow *warningWindow;
@property (strong, nonatomic) NSTimer *textToSpeechTimer;
@property (strong, nonatomic) NSDate *lastCheckForSessions;

@property (strong, nonatomic) TSJavelinAPIEntourageMember *memberToMonitor;
@property (strong, nonatomic) NSTimer *singleSessionRefreshTimer;
@property (strong, nonatomic) NSTimer *allSessionRefreshTimer;

@property (strong, nonatomic) NSArray *entourageMemberAnnotations;
@property (strong, nonatomic) NSArray *entourageMemberOverlays;
@property (strong, nonatomic) NSArray *entourageMemberStartEndAnnotations;

@end

@implementation TSEntourageSessionManager

static TSEntourageSessionManager *_sharedEntourageManagerInstance = nil;
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
        return [TSEntourageSessionManager initSharedEntourageManagerWithHomeView:nil];
    }
    
    return _sharedEntourageManagerInstance;
}

- (instancetype)initWithHomeView:(TSHomeViewController *)homeView {
    self = [super init];
    if (self) {
        _isEnabled = NO;
        self.homeView = homeView;
        self.routeManager = [[TSRouteManager alloc] initWithMapView:homeView.mapView];
        [self getAllEntourageSessions:nil];
    }
    return self;
}

- (void)startEntourageWithMembers:(NSSet *)members ETA:(NSTimeInterval)eta completion:(TSEntourageSessionManagerPostCompletion)completion {
    
    _selectedETA = eta;
    [_homeView entourageModeOn];
    [_routeManager showOnlySelectedRoute];
    
    _endRegions = [self regionsForEndPoint];
    
    [self resetTimerWithTimeInterval:eta];
    [self checkRegion:[TSLocationController sharedLocationController].location];
    
    [self syncEntourageMembers:members];
    
    if (completion) {
        completion(YES);
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:TSEntourageSessionManagerWarning911]) {
        _warningWindow = [[TSPopUpWindow alloc] initWithRepeatCheckBox:TSEntourageSessionManagerWarning911
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


- (void)manuallyEndTracking {
    
    CLLocationDistance distance = [[TSLocationController sharedLocationController].location distanceFromLocation:_routeManager.destinationMapItem.placemark.location] ;
    if (distance <= 300) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"You are %@ from your destination", [TSUtilities formattedStringForDistanceInUSStandard:distance]]
                                                                                 message:@"Would you like notify entourage members of your arrival?"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.homeView clearEntourageAndResetMap];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Arrived" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self arrivedAtDestination];
        }]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.homeView presentViewController:alertController animated:YES completion:nil];
        });
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSEntourageSessionManagerTimerDidStart object:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

- (void)timerEnded {
    
    [self resetEndTimer];
    
    [TSLocalNotification say:kSpeechEntourageNotify];
    
    [TSLocalNotification presentLocalNotification:kLocalNoteEnterPasscode];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSEntourageSessionManagerTimerDidEnd object:@"T"];
}

- (void)resetEndTimer {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [_endTimer invalidate];
    _endTimer = nil;
    
    [self resetSpeechTimer];
}

- (void)recalculateEntourageTimerETA {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert Disarmed"
                                                                             message:@"Would you like to continue Entourage?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"End Route" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.homeView clearEntourageAndResetMap];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Update ETA" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self newMapsETA];
    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.homeView presentViewController:alertController animated:YES completion:nil];
    });
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

#pragma mark - Sync Members


- (void)syncEntourageMembers:(NSSet *)members {
    
    [[TSJavelinAPIClient sharedClient] syncEntourageMembers:members.allObjects completion:^(id responseObject, NSError *error) {
        
        if (!error) {
            NSLog(@"Saved entourage members");
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Pop Up Window Delegate

- (void)didDismissWindow:(UIWindow *)window {
    
    if (window == _warningWindow) {
        _warningWindow = nil;
    }
}


#pragma mark Home View

- (void)removeHomeViewController {
    
    [TSEntourageSessionManager initSharedEntourageManagerWithHomeView:nil];
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
    
    if (_isEnabled) {
        [self saySecondsRemaining:[_endTimer.fireDate timeIntervalSinceDate:[NSDate date]]];
        
        [self setNextTimer];
    }
}

- (void)resetSpeechTimer {
    
    [_textToSpeechTimer invalidate];
    _textToSpeechTimer = nil;
}


#pragma mark - Entourage Member Sessions

- (void)getAllEntourageSessions:(void (^)(NSArray *entourageMembers))completion {
    
    [self _getAllEntourageSessions:completion];
    
    [self startAllSessionRefreshTimer];
}

- (void)timerGetAllSessions {
    
    [self _getAllEntourageSessions:nil];
}

- (void)_getAllEntourageSessions:(void (^)(NSArray *entourageMembers))completion {
    
    [[TSJavelinAPIClient sharedClient] getEntourageSessionsWithLocationsSince:_lastCheckForSessions completion:^(NSArray *entourageMembers, NSError *error) {
        if (error) {
            if (completion) {
                completion([TSJavelinAPIClient loggedInUser].usersWhoAddedUser);
            }
        }
        else {
            if (completion) {
                [[TSJavelinAPIClient loggedInUser] setUsersWhoAddedUserWithoutKVO:[TSJavelinAPIEntourageMember sortedMemberArray:entourageMembers]];
                completion(entourageMembers);
            }
            else {
                [TSJavelinAPIClient loggedInUser].usersWhoAddedUser = [TSJavelinAPIEntourageMember sortedMemberArray:entourageMembers];
            }
            
            [self refreshEntourageMemberOverlaysAndAnnotations];
        }
    }];
    
    _lastCheckForSessions = [NSDate date];
}

- (void)startAllSessionRefreshTimer {
    
    [self stopSingleSessionRefreshTimer];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _allSessionRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerGetAllSessions) userInfo:nil repeats:YES];
        _allSessionRefreshTimer.tolerance = 5;
    }];
}

- (void)stopAllSessionRefreshTimer {
    
    [_allSessionRefreshTimer invalidate];
    _allSessionRefreshTimer = nil;
}

#pragma mark Single Session

- (void)showSessionForMember:(TSJavelinAPIEntourageMember *)member {
    
    [_homeView.mapView removeAnnotations:_entourageMemberStartEndAnnotations];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:2];
    TSSelectedDestinationAnnotation *destination;
    destination = [[TSSelectedDestinationAnnotation alloc] initWithCoordinates:member.session.endLocation.placemark.coordinate
                                                                     placeName:member.session.endLocation.name
                                                                   description:nil
                                                                    travelType:member.session.transportType];
    if (destination) {
        [mutableArray addObject:destination];
    }
    
    TSStartAnnotation *start;
    start = [[TSStartAnnotation alloc] initWithCoordinates:member.session.startLocation.placemark.coordinate
                                                 placeName:member.session.startLocation.name
                                               description:nil];
    if (start) {
        [mutableArray addObject:start];
    }
    
    _entourageMemberStartEndAnnotations = [NSArray arrayWithArray:mutableArray];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_homeView.mapView addAnnotations:_entourageMemberStartEndAnnotations];
        [_homeView setIsTrackingUser:NO animateToUser:NO];
        [_homeView.mapView showAnnotations:_entourageMemberStartEndAnnotations animated:YES];
        [self closeDrawer];
    }];
}

- (void)removeCurrentMemberSession {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_homeView.mapView removeAnnotations:_entourageMemberStartEndAnnotations];
        [_homeView setIsTrackingUser:YES animateToUser:YES];
    }];
}

- (void)startMonitoringEntourageMember:(TSJavelinAPIEntourageMember *)member {
    
    _memberToMonitor = member;
    
    [self getEntourageMemberLocationUpdate];
    [self startSingleSessionRefreshTimer];
}

- (void)stopMonitoringEntourageMember {
    
    _memberToMonitor = nil;
    [self stopSingleSessionRefreshTimer];
}


- (void)startSingleSessionRefreshTimer {
    
    [self stopSingleSessionRefreshTimer];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _singleSessionRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getEntourageMemberLocationUpdate) userInfo:nil repeats:YES];
        _singleSessionRefreshTimer.tolerance = 5;
    }];
}

- (void)stopSingleSessionRefreshTimer {
    
    [_singleSessionRefreshTimer invalidate];
    _singleSessionRefreshTimer = nil;
}

- (void)getEntourageMemberLocationUpdate {
    
    [[TSJavelinAPIClient sharedClient] getEntourageSession:_memberToMonitor.session withLocationsSince:nil completion:^(TSJavelinAPIEntourageSession *entourageSession, NSError *error) {
        if (entourageSession) {
            _memberToMonitor.session = entourageSession;
        }
    }];
}


#pragma mark - Entourage Map

- (void)refreshEntourageMemberOverlaysAndAnnotations {
    
    [self refreshEntourageMemberAnnotations];
    [self refreshEntourageMemberOverlays];
}

- (void)locateEntourageMember:(TSJavelinAPIEntourageMember *)member {
    
    
    float maxDelta = 0.06;
    float delta = _homeView.mapView.region.span.longitudeDelta;
    if (delta > maxDelta) {
        delta = maxDelta;
    }
    
    [_homeView moveMapViewToCoordinate:member.mapAnnotation.coordinate spanDelta:delta];
//    [_homeView.mapView selectAnnotation:member.mapAnnotation animated:YES];
    [self closeDrawer];
}

- (void)closeDrawer {
    TSAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.dynamicsDrawerViewController.paneState != MSDynamicsDrawerPaneStateClosed) {
        [delegate.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:nil];
    }
}

#pragma mark Entourage Annotations

- (void)refreshEntourageMemberAnnotations {
    
    [_homeView.mapView removeAnnotations:_entourageMemberAnnotations];
    [self addEntourageMembersToMap:[TSJavelinAPIClient loggedInUser].usersWhoAddedUser];
}

- (void)addEntourageMembersToMap:(NSArray *)entourageMembers {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:entourageMembers.count];
    
    for (TSJavelinAPIEntourageMember *member in entourageMembers) {
        
        TSEntourageMemberAnnotation *annotation;
        if (member.location) {
            annotation = [[TSEntourageMemberAnnotation alloc] initWithCoordinates:member.location.coordinate placeName:member.name description:[TSUtilities dateDescriptionSinceNow:member.location.timestamp]];
            annotation.member = member;
            [mutableArray addObject:annotation];
            member.mapAnnotation = annotation;
        }
    }
    
    _entourageMemberAnnotations = [NSArray arrayWithArray:mutableArray];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_homeView.mapView addAnnotations:_entourageMemberAnnotations];
    }];
}

#pragma mark Entourage Overlays

- (void)refreshEntourageMemberOverlays {
    
    [_homeView.mapView removeOverlays:_entourageMemberOverlays];
    [self addEntourageSessionPolylines:[TSJavelinAPIClient loggedInUser].usersWhoAddedUser];
}

- (void)addEntourageSessionPolylines:(NSArray *)entourageMembers {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:entourageMembers.count];
    
    for (TSJavelinAPIEntourageMember *member in entourageMembers) {
        
        if (member.session) {
            [mutableArray addObject:member.session.locations];
        }
    }
    
    _entourageMemberOverlays = [NSArray arrayWithArray:mutableArray];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_homeView.mapView addOverlays:_entourageMemberOverlays level:MKOverlayLevelAboveRoads];
    }];
}

@end
