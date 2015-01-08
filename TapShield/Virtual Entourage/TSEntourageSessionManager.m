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
#import "TSAlertAnnotation.h"
#import "CLLocation+Utilities.h"
#import "NSDate+Utilities.h"
#import "TSNotifySelectionViewController.h"

#define WALKING_RADIUS_MIN 25
#define DRIVING_RADIUS_MIN 50

#define NOTIFICATION_TIMES @(60*5), @(60), @(30), @(10), @(5), nil

#define WARNING_TITLE @"Please Note"
#define WARNING_MESSAGE @"If you fail to arrive, TapShield is unable to automatically call 911 when the app is running in the background. Authorities will be alerted if you are within your organization's boundaries"

static NSString * const kSpeechRemaining = @"%@ remaining";
static NSString * const kSpeechEntourageNotify = @"Entourage will be notified in 10 seconds, please enter your pass code.";
static NSString * const kSpeechEntourageArrived = @"You have arrived at your destination";
static NSString * const kLocalNoteArrived = @"You have arrived at %@";

static NSString * const kLocalNoteEnterPasscode = @"Entourage will be notified in 10 seconds, please enter passcode.";

static NSString * const kGoogleMapsPath = @"http://maps.google.com/maps?q=%f,%f";

static NSString * const TSEntourageSessionManagerMembersPosted = @"TSEntourageSessionManagerMembersPosted";
static NSString * const TSEntourageSessionManagerWarning911 = @"TSEntourageSessionManagerWarning911";

NSString * const TSEntourageSessionManagerTimerDidStart = @"TSEntourageSessionManagerTimerDidStart";
NSString * const TSEntourageSessionManagerTimerDidEnd = @"TSEntourageSessionManagerTimerDidEnd";

static NSString * const TSDestinationSearchPastResults = @"TSDestinationSearchPastResults";

@interface TSEntourageSessionManager ()

@property (strong, nonatomic) TSPopUpWindow *warningWindow;
@property (strong, nonatomic) NSTimer *textToSpeechTimer;
@property (strong, nonatomic) NSDate *lastCheckForSessions;

@property (strong, nonatomic) TSJavelinAPIEntourageMember *memberToMonitor;
@property (strong, nonatomic) NSTimer *singleSessionRefreshTimer;
@property (strong, nonatomic) NSTimer *allSessionRefreshTimer;

@property (strong, nonatomic) NSMutableDictionary *entourageMemberAnnotations;
@property (strong, nonatomic) NSArray *entourageMemberOverlays;
@property (strong, nonatomic) NSArray *entourageMemberStartEndAnnotations;

@property (nonatomic, strong) UIButton *timeButton;

@property (strong, nonatomic) NSTimer *clockTimer;

@property (strong, nonatomic) TSBaseLabel *timerLabel;
@property (strong, nonatomic) TSBaseLabel *etaLabel;
@property (assign, nonatomic) NSUInteger changeAlpha;

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

- (void)setHomeView:(TSHomeViewController *)homeView {
    
    _homeView = homeView;
    
    _showEntourageAnnotationsAndOverlays = YES;
    [self hardRefreshMap];
}

- (void)resumePreviousEntourage {
    
    TSJavelinAPIEntourageSession *session = [TSJavelinAPIClient loggedInUser].entourageSession;
    if (session) {
        if (session.eta.isInPast) {
            if (session.eta.timeIntervalUntilNow > 1800) {
                [[TSJavelinAPIClient sharedClient] cancelEntourageSession:nil];
                return;
            }
        }
        _routeManager.selectedRoute = session.route;
        _routeManager.destinationMapItem = session.endLocation.mapItem;
        _routeManager.destinationTransportType = session.transportType;
        [self trackingSession:session];
        
        if (!_routeManager.selectedRoute) {
            [_routeManager getAndShowBestRoute];
        }
    }
}

- (void)trackingSession:(TSJavelinAPIEntourageSession *)session {
    
    if (!_routeManager.destinationAnnotation) {
        [_routeManager userSelectedDestination:session.endLocation.mapItem forTransportType:session.transportType];
    }
    [_homeView entourageModeOn];
    [_routeManager showOnlySelectedRoute];
    _endRegions = [self regionsForEndPoint];
    [self resetTimerWithTimeInterval:[session.eta timeIntervalSinceDate:[NSDate date]]];
    [self checkRegion:[TSLocationController sharedLocationController].location];
}

- (void)updateTrackingWithETA:(NSTimeInterval)eta completion:(TSEntourageSessionManagerPostCompletion)completion {
    
    [[TSJavelinAPIClient sharedClient] updateEntourageSessionETA:[[NSDate date] dateByAddingTimeInterval:eta] completion:completion];
    [self trackingSession:[TSJavelinAPIClient loggedInUser].entourageSession];
}

- (void)startTrackingWithETA:(NSTimeInterval)eta completion:(TSEntourageSessionManagerPostCompletion)completion {
    
    if ([TSJavelinAPIClient loggedInUser].entourageSession) {
        [self updateTrackingWithETA:eta completion:completion];
        return;
    }
    
    TSJavelinAPIEntourageSession *session = [[TSJavelinAPIEntourageSession alloc] init];
    session.endLocation = [[TSJavelinAPINamedLocation alloc] initWithMapItem:_routeManager.destinationMapItem];
    session.startLocation = [[TSJavelinAPINamedLocation alloc] initWithMapItem:_homeView.userLocationItem];
    session.eta = [[NSDate date] dateByAddingTimeInterval:eta];
    session.startTime = [NSDate date];
    session.transportType = _routeManager.destinationTransportType;
    session.route = _routeManager.selectedRoute;
    
    [[TSJavelinAPIClient sharedClient] postNewEntourageSession:session completion:completion];
    
    [self trackingSession:[TSJavelinAPIClient loggedInUser].entourageSession];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:TSEntourageSessionManagerWarning911]) {
        _warningWindow = [[TSPopUpWindow alloc] initWithRepeatCheckBox:TSEntourageSessionManagerWarning911
                                                                  title:WARNING_TITLE
                                                                message:WARNING_MESSAGE];
        _warningWindow.popUpDelegate = self;
        [_warningWindow show];
    }
    
    [self addMapItemToSavedSelections:_routeManager.destinationMapItem];
}

- (NSArray *)regionsForEndPoint {
    
    CLCircularRegion *destinationRegion = [[CLCircularRegion alloc] initWithCenter:_routeManager.destinationAnnotation.coordinate
                                                                            radius:_routeManager.safeZoneOverlay.radius
                                                                        identifier:_routeManager.destinationAnnotation.title];
    
    return @[destinationRegion];
}

- (void)checkRegion:(CLLocation *)userLocation  {
    
    if (!userLocation) {
        return;
    }
    
    BOOL contains = NO;
    
    for (CLCircularRegion *region in [_endRegions copy]) {
        if ([region containsCoordinate:userLocation.coordinate]) {
            contains = YES;
        }
    }
    
    if (contains) {
        _routeManager.safeZoneOverlay.inside = YES;
        [self performSelector:@selector(stopEntourageArrived) withObject:nil afterDelay:10.0];
    }
    else {
        _routeManager.safeZoneOverlay.inside = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}


- (void)manuallyEndTracking {
    
    CLLocationDistance distance = [[TSLocationController sharedLocationController].location distanceFromLocation:_routeManager.destinationMapItem.placemark.location] ;
    if (distance <= 300 && [TSLocationController sharedLocationController].location) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"You are %@ from your destination", [TSUtilities formattedStringForDistanceInUSStandard:distance]]
                                                                                 message:@"Would you like notify entourage members of your arrival?"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self stopEntourageCancelled];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Arrived" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self stopEntourageArrived];
        }]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.homeView presentViewController:alertController animated:YES completion:nil];
        });
    }
    else {
        [self stopEntourageCancelled];
    }
}

- (void)stopEntourage {
    
    _isEnabled = NO;
    [_homeView clearEntourageMap];
    
    [self resetEndTimer];
    [self stopNavBarTimer];
    [self hideETAButton];
    
    [_routeManager clearRouteAndMapData];
    [_homeView.statusView setShouldShowRouteInfo:NO];
}

- (void)stopEntourageCancelled {
    
    [self stopEntourage];
    [[TSJavelinAPIClient sharedClient] cancelEntourageSession:nil];
}

- (void)stopEntourageArrived {
    
    _endRegions = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopEntourageArrived) object:nil];
    
    if (!_isEnabled) {
        return;
    }
    
    [TSLocalNotification say:kSpeechEntourageArrived];
    
    [TSLocalNotification presentLocalNotification:[NSString stringWithFormat:kLocalNoteArrived, _routeManager.destinationMapItem.name]];
    
    [[TSJavelinAPIClient sharedClient] arrivedForEntourageSession:nil];
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self stopEntourage];
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            [[TSLocationController sharedLocationController] stopLocationUpdates];
            if ([TSJavelinAPIClient loggedInUser] && [[TSJavelinAPIClient loggedInUser] shouldUpdateAlwaysVisibleLocation]) {
                [[TSLocationController sharedLocationController] startSignificantChangeUpdates:nil];
            }
        }
    }];
}

- (void)stopEntourageNonArrival {
    
    [self stopEntourage];
    [TSJavelinAPIClient loggedInUser].entourageSession = nil;
    [[TSJavelinAPIClient sharedClient].authenticationManager archiveLoggedInUser];
}


#pragma mark - Timer

- (void)showETAButtonOnHomeView {
    
    _homeView.showLogoInNavBar = NO;
    
    _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_timeButton addTarget:_homeView action:@selector(showTimeAdjustViewController) forControlEvents:UIControlEventTouchUpInside];
    _timeButton.titleLabel.font = [UIFont fontWithName:kFontWeightThin size:28];
    [_timeButton setTitleColor:[TSColorPalette tapshieldBlue] forState:UIControlStateNormal];
    [_timeButton setTitleColor:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [_homeView.navigationItem setTitleView:_timeButton];
}


- (void)hideETAButton {
    
    [_timeButton removeFromSuperview];
    _timeButton = nil;
    _homeView.showLogoInNavBar = YES;
}

- (void)timeAdjusted {
    
    NSDate *fireDate = [TSEntourageSessionManager sharedManager].endTimer.fireDate;
    
    NSTimeInterval time = [fireDate timeIntervalSinceDate:[NSDate date]];
    
    [_timeButton setTitle:[TSUtilities formattedStringForTime:time] forState:UIControlStateNormal];
    
    if (time < 60) {
        [_timeButton setTitleColor:[TSColorPalette alertRed] forState:UIControlStateNormal];
        [_timeButton setTitleColor:[[TSColorPalette alertRed] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    }
    else {
        [_timeButton setTitleColor:[TSColorPalette tapshieldBlue] forState:UIControlStateNormal];
        [_timeButton setTitleColor:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    }
    
    [_timeButton sizeToFit];
    [_timeButton setNeedsDisplay];
}

- (void)resetTimerWithTimeInterval:(NSTimeInterval)interval {
    
    _isEnabled = YES;
    
    [self resetEndTimer];
    _endTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                 target:self
                                               selector:@selector(timerEnded)
                                               userInfo:nil
                                                repeats:NO];
    _endTimer.tolerance = 1;
    [[NSRunLoop currentRunLoop] addTimer:_endTimer forMode:NSRunLoopCommonModes];
    [self scheduleLocalNotifications];
    [self setNextTimer];
//    [self startStatusBarTimer];
    [self startNavBarTimer];
    [self showETAButtonOnHomeView];
    
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
        [self stopEntourageCancelled];
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
        if (expectedTravelTime < 60) {
            expectedTravelTime = 60;
        }
        [self resetTimerWithTimeInterval:expectedTravelTime];
        [self updateTrackingWithETA:expectedTravelTime completion:nil];
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
        _textToSpeechTimer.tolerance = 1;
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

- (void)setShowEntourageAnnotationsAndOverlays:(BOOL)showEntourageAnnotationsAndOverlays {
    
    if (showEntourageAnnotationsAndOverlays == _showEntourageAnnotationsAndOverlays) {
        return;
    }
    
    _showEntourageAnnotationsAndOverlays = showEntourageAnnotationsAndOverlays;
    
    if (showEntourageAnnotationsAndOverlays) {
        [_homeView.mapView addAnnotations:_entourageMemberAnnotations.allValues];
        [_homeView.mapView addOverlays:_entourageMemberOverlays];
    }
    else {
        [_homeView.mapView removeAnnotations:_entourageMemberAnnotations.allValues];
        [_homeView.mapView removeAnnotations:_entourageMemberStartEndAnnotations];
        [_homeView.mapView removeOverlays:_entourageMemberOverlays];
    }
}

- (void)hardRefreshMap {
    [_homeView.mapView removeAnnotations:_entourageMemberAnnotations.allValues];
    [_homeView.mapView removeAnnotations:_entourageMemberStartEndAnnotations];
    [_homeView.mapView removeOverlays:_entourageMemberOverlays];
    [_homeView.mapView addAnnotations:_entourageMemberAnnotations.allValues];
    [_homeView.mapView addOverlays:_entourageMemberOverlays];
}


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
    
    [self stopAllSessionRefreshTimer];
    
    if (!_allSessionRefreshTimer) {
        _allSessionRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerGetAllSessions) userInfo:nil repeats:YES];
    }
    _allSessionRefreshTimer.tolerance = 5;
}

- (void)stopAllSessionRefreshTimer {
    
    [_allSessionRefreshTimer invalidate];
    _allSessionRefreshTimer = nil;
}

#pragma mark Single Session

- (void)showSessionForMember:(TSJavelinAPIEntourageMember *)member {
    
    [self showSessionAnnotations:[self createStartEndAnnotations:member.session]];
}

- (void)showSessionAnnotations:(NSArray *)array {
    
    [_homeView.mapView removeAnnotations:_entourageMemberStartEndAnnotations];
    
    _entourageMemberStartEndAnnotations = [NSArray arrayWithArray:array];
    
    if (!_entourageMemberStartEndAnnotations.count) {
        return;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_homeView.mapView addAnnotations:_entourageMemberStartEndAnnotations];
        [_homeView setIsTrackingUser:NO animateToUser:NO];
        [_homeView.mapView showAnnotations:_entourageMemberStartEndAnnotations animated:YES];
        [self closeDrawer];
    }];
}

- (NSMutableArray *)createStartEndAnnotations:(TSJavelinAPIEntourageSession *)session {
    
    NSMutableArray *mutableArray = [self createDestinationAnnotationArray:session];
    
    TSStartAnnotation *start;
    start = [[TSStartAnnotation alloc] initWithCoordinates:session.startLocation.location.coordinate
                                                 placeName:session.startLocation.name
                                               description:nil];
    if (start) {
        [mutableArray addObject:start];
    }
    
    return mutableArray;
}

- (NSMutableArray *)createDestinationAnnotationArray:(TSJavelinAPIEntourageSession *)session {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:2];
    TSSelectedDestinationAnnotation *destination;
    destination = [self createDestinationAnnotation:session];
    if (destination) {
        [mutableArray addObject:destination];
    }
    
    return mutableArray;
}

- (TSSelectedDestinationAnnotation *)createDestinationAnnotation:(TSJavelinAPIEntourageSession *)session {
    
    TSSelectedDestinationAnnotation *destination;
    destination = [[TSSelectedDestinationAnnotation alloc] initWithCoordinates:session.endLocation.location.coordinate
                                                                     placeName:session.endLocation.name
                                                                   description:nil
                                                                    travelType:session.transportType];
    return destination;
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
    
    [_homeView moveMapViewToCoordinate:member.location.coordinate spanDelta:delta];
    
    if ([_entourageMemberAnnotations objectForKey:member.matchedUser.url]) {
        [_homeView.mapView selectAnnotation:[_entourageMemberAnnotations objectForKey:member.matchedUser.url] animated:YES];
    }
    
    [self closeDrawer];
}

- (void)closeDrawer {
    TSAppDelegate *delegate = (TSAppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.dynamicsDrawerViewController.paneState != MSDynamicsDrawerPaneStateClosed) {
        [delegate.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:nil];
    }
}

#pragma mark Entourage Annotations

- (void)refreshEntourageMemberAnnotations {
    [self addEntourageMembersToMap:[TSJavelinAPIClient loggedInUser].usersWhoAddedUser];
}

- (void)addEntourageMembersToMap:(NSArray *)entourageMembers {
    
    if (!_entourageMemberAnnotations) {
        _entourageMemberAnnotations = [[NSMutableDictionary alloc] initWithCapacity:entourageMembers.count];
    }
    
    NSMutableDictionary *keysToRemove = [[NSMutableDictionary alloc] initWithObjects:_entourageMemberAnnotations.allKeys forKeys:_entourageMemberAnnotations.allKeys];
    
    for (TSJavelinAPIEntourageMember *member in entourageMembers) {
        
        if (member.location) {
            
            TSEntourageMemberAnnotation *annotation = [_entourageMemberAnnotations objectForKey:member.matchedUser.url];
            
            if (annotation) {
                [keysToRemove removeObjectForKey:member.matchedUser.url];
                
                if (!CLLocationCoordinate2DIsApproxEqual(member.location.coordinate, annotation.coordinate, 0.00005)) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [UIView animateWithDuration:1.0f delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
                            annotation.coordinate = member.location.coordinate;
                        } completion:nil];
                    }];
                }
            }
            else {
                annotation = [[TSEntourageMemberAnnotation alloc] initWithCoordinates:member.location.coordinate placeName:member.name description:[member.location.timestamp dateDescriptionSinceNow]];
                annotation.member = member;
                [_entourageMemberAnnotations setObject:annotation forKey:member.matchedUser.url];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    if (_showEntourageAnnotationsAndOverlays) {
                        [_homeView.mapView addAnnotation:annotation];
                    }
                }];
            }
        }
    }
    
    for (NSString *key in keysToRemove.allKeys) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_homeView.mapView removeAnnotation:[_entourageMemberAnnotations objectForKey:key]];
        }];
    }
    [_entourageMemberAnnotations removeObjectsForKeys:keysToRemove.allKeys];
}

#pragma mark Entourage Overlays

- (void)refreshEntourageMemberOverlays {
    
    [_homeView.mapView removeOverlays:_entourageMemberOverlays];
    [self addEntourageSessionPolylines:[TSJavelinAPIClient loggedInUser].usersWhoAddedUser];
}

- (void)addEntourageSessionPolylines:(NSArray *)entourageMembers {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:entourageMembers.count];
    
    for (TSJavelinAPIEntourageMember *member in entourageMembers) {
        
        if (member.session.locations) {
            [mutableArray addObject:member.session.locations];
        }
    }
    
    _entourageMemberOverlays = [NSArray arrayWithArray:mutableArray];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (_showEntourageAnnotationsAndOverlays) {
            [_homeView.mapView addOverlays:_entourageMemberOverlays level:MKOverlayLevelAboveRoads];
        }
    }];
}


#pragma mark - Entourage Timer


- (void)startNavBarTimer {
    
    [self stopNavBarTimer];
    if (!_clockTimer) {
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                       target:self
                                                     selector:@selector(timeAdjusted)
                                                     userInfo:nil
                                                      repeats:YES];
        _clockTimer.tolerance = 0.1;
        [[NSRunLoop currentRunLoop] addTimer:_clockTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopNavBarTimer {
    
    [_clockTimer invalidate];
    _clockTimer = nil;
}


//- (void)startStatusBarTimer {
//    
//    if (!_clockTimer) {
//        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
//                                                       target:self
//                                                     selector:@selector(startStatusBarTimer)
//                                                     userInfo:nil
//                                                      repeats:YES];
//        _clockTimer.tolerance = 0.2;
//        [[NSRunLoop currentRunLoop] addTimer:_clockTimer forMode:NSRunLoopCommonModes];
//    }
//    
//    NSDate *fireDate = [TSEntourageSessionManager sharedManager].endTimer.fireDate;
//    
//    NSTimeInterval time = [fireDate timeIntervalSinceDate:[NSDate date]];
//    
//    if (!_timerLabel.superview) {
//        _changeAlpha = 0;
//        UIView *statusBar = [TSAppDelegate statusBar];
//        _timerLabel = [[TSBaseLabel alloc] init];
//        _timerLabel.backgroundColor = [TSColorPalette clearColor];
//        _timerLabel.textColor = [TSColorPalette tapshieldBlue];
//        _timerLabel.frame = statusBar.bounds;
//        _timerLabel.textAlignment = NSTextAlignmentCenter;
//        _timerLabel.font = [UIFont fontWithName:kFontWeightSemiBold size:12];
//        [statusBar addSubview:_timerLabel];
//    }
//    
//    if (time < 60) {
//        _timerLabel.textColor = [TSColorPalette alertRed];
//    }
//    else {
//        _timerLabel.textColor = [TSColorPalette tapshieldBlue];
//    }
//    
//    _timerLabel.text = [NSString stringWithFormat:@"%@ ETA", [TSUtilities formattedStringForTime:time]];
//    
//    NSInteger intervalChange = 25;
//    if (_changeAlpha > intervalChange || time <= 60) {
//        [self setTimeViewOnStatusBar:[TSAppDelegate statusBar] alpha:0.0];
//        _timerLabel.alpha = 1.0;
//        if (_changeAlpha == intervalChange*2) {
//            _changeAlpha = 0;
//        }
//    }
//    else {
//        [self setTimeViewOnStatusBar:[TSAppDelegate statusBar] alpha:1.0];
//        _timerLabel.alpha = 0.0;
//    }
//    
//    _changeAlpha++;
//}
//
//- (BOOL)setTimeViewOnStatusBar:(UIView *)view alpha:(float)alpha {
//    
//    CGRect frame = CGRectMake(125, 0, 70, 20);
//    
//    for (UIView *subview in view.subviews) {
//        if (CGRectContainsRect(frame, subview.frame)) {
//            subview.alpha = alpha;
//            [subview setHidden:!alpha];
//            return YES;
//        }
//        else {
//            if ([self setTimeViewOnStatusBar:subview alpha:alpha]) {
//                return YES;
//            }
//        }
//    }
//    return NO;
//}


//- (void)stopStatusBarTimer {
//    
//    [_clockTimer invalidate];
//    _clockTimer = nil;
//    
//    [_timerLabel removeFromSuperview];
//    _timerLabel = nil;
//    
//    [self setTimeViewOnStatusBar:[TSAppDelegate statusBar] alpha:1.0];
//}

#pragma mark - Entourage User Notifications

- (void)actionForEntourageNotificationObject:(TSJavelinAPIUserNotification *)notification {
    
    if (notification.alert) {
        [self viewAlertLocation:notification.alert];
    }
    else if (notification.entourageSession) {
        [self viewEntourageSessionDestination:notification.entourageSession];
    }
}

- (void)viewAlertLocation:(TSJavelinAPIAlert *)alert {
    
    [self showSessionAnnotations:[self createAlertAnnotationArray:alert]];
}


- (void)viewEntourageSessionDestination:(TSJavelinAPIEntourageSession *)session {
    
    [self showSessionAnnotations:[self createDestinationAnnotationArray:session]];
}


- (NSMutableArray *)createAlertAnnotationArray:(TSJavelinAPIAlert *)alert {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:2];
    TSAlertAnnotation *alertLocation = [self createAlertAnnotation:alert];
    if (alertLocation) {
        [mutableArray addObject:alertLocation];
    }
    
    return mutableArray;
}

- (TSAlertAnnotation *)createAlertAnnotation:(TSJavelinAPIAlert *)alert {
    
    NSDate *date = alert.lastModified;
    
    if (alert.disarmedTime) {
        date = alert.disarmedTime;
    }
    
    TSAlertAnnotation *alertAnnotation;
    alertAnnotation = [[TSAlertAnnotation alloc] initWithCoordinates:alert.latestLocation.coordinate
                                                           placeName:alert.agencyUser.fullName
                                                         description:[date dateDescriptionSinceNow]];
    alertAnnotation.alert = alert;
    return alertAnnotation;
}


#pragma mark - Speech Delegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}


#pragma mark - Saved MapItems

- (NSMutableArray *)previousMapItems {
    
    NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:TSDestinationSearchPastResults]];
    
    if (savedArray) {
        return [[NSMutableArray alloc] initWithArray:savedArray];
    }
    
    return nil;
}

- (void)archivePreviousMapItems:(NSArray *)mapItems {
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:mapItems] forKey:TSDestinationSearchPastResults];
}

- (NSMutableArray *)addMapItemToSavedSelections:(MKMapItem *)mapItem {
    
    NSMutableArray *previousMapItemSelections = [self previousMapItems];
    
    if (!previousMapItemSelections) {
        previousMapItemSelections = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    NSMutableArray *itemsToKeep = [NSMutableArray arrayWithCapacity:[previousMapItemSelections count]];
    for (MKMapItem *item in previousMapItemSelections) {
        
        if ([item isEqual:mapItem]) {
            continue;
        }
        else if (item.name && item.placemark.thoroughfare && item.placemark.postalCode) {
            if ([item.name isEqualToString:mapItem.name] && [item.placemark.thoroughfare isEqualToString:mapItem.placemark.thoroughfare] && [item.placemark.postalCode isEqualToString:mapItem.placemark.postalCode]) {
                continue;
            }
        }
        else if (item.name && item.placemark.locality && item.placemark.administrativeArea) {
            if ([item.name isEqualToString:mapItem.name] && [item.placemark.locality isEqualToString:mapItem.placemark.locality] && [item.placemark.administrativeArea isEqualToString:mapItem.placemark.administrativeArea]) {
                continue;
            }
        }
        
        [itemsToKeep addObject:item];
    }
    
    [previousMapItemSelections setArray:itemsToKeep];
    [previousMapItemSelections insertObject:mapItem atIndex:0];
    
    if (previousMapItemSelections.count > 20) {
        [previousMapItemSelections removeObjectsInRange:NSMakeRange(20, previousMapItemSelections.count-20)];
    }
    
    [self archivePreviousMapItems:previousMapItemSelections];
    
    return previousMapItemSelections;
}



@end
