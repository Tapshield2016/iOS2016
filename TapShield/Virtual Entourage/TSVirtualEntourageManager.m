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

#define WALKING_RADIUS 50
#define DRIVING_RADIUS 100

#define ARRIVAL_MESSAGE @"%@ has arrived at %@, %@."
#define NON_ARRIVAL_MESSAGE @"Please be advised, %@ has not made it to %@, %@, within the estimated time of arrival."

static NSString * const TSVirtualEntourageManagerMembersPosted = @"TSVirtualEntourageManagerMembersPosted";

NSString * const TSVirtualEntourageManagerTimerDidStart = @"TSVirtualEntourageManagerTimerDidStart";
NSString * const TSVirtualEntourageManagerTimerDidEnd = @"TSVirtualEntourageManagerTimerDidEnd";

@interface TSVirtualEntourageManager ()

@property (strong, nonatomic) TSHomeViewController *homeView;


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
    
    NSLog(@"%@", _routeManager.destinationMapItem.placemark.region);
    _endRegion = [self regionForEndPoint];
    
    __weak typeof(self) weakSelf = self;
    [self addOrRemoveMembers:members completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf resetTimerWithTimeInterval:eta];
            
            if (completion) {
                completion(finished);
            }
        }
    }];
}

- (CLCircularRegion *)regionForEndPoint {
    
    float radius;
    if (_routeManager.destinationTransportType == MKDirectionsTransportTypeWalking) {
        radius = WALKING_RADIUS;
    }
    else {
        radius = DRIVING_RADIUS;
    }
    
    MKMapItem *destination = _routeManager.destinationMapItem;
    return [[CLCircularRegion alloc] initWithCenter:destination.placemark.location.coordinate
                                             radius:radius
                                         identifier:destination.name];
}

- (void)checkRegion:(CLLocation *)userLocation {
    
    if ([_endRegion containsCoordinate:userLocation.coordinate]) {
        
        _endRegion = nil;
        [self arrivedAtDestination];
    }
}

- (void)arrivedAtDestination {
    
    if (!_isEnabled) {
        return;
    }
    
    [_homeView clearEntourageAndResetMap];
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].firstName, [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].lastName];
    NSString *destinationName = _routeManager.destinationMapItem.name;
    NSString *message = [NSString stringWithFormat:ARRIVAL_MESSAGE, fullName, destinationName, [TSUtilities formattedAddressWithoutNameFromMapItem:_routeManager.destinationMapItem]];
    
        [[TSJavelinAPIClient sharedClient] notifyEntourageMembers:message completion:^(id responseObject, NSError *error) {
            
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
    
    [[TSJavelinAPIClient sharedClient] notifyEntourageMembers:message completion:^(id responseObject, NSError *error) {
        
    }];
}

- (void)addOrRemoveMembers:(NSSet *)members completion:(TSVirtualEntourageManagerPostCompletion)completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        
        [self findMembersToDelete:_entourageMembersPosted newMembers:members];
        
        if (members.count) {
            if (completion) {
                _finishedPosting = completion;
            }
            
            [self postEntourageMembers:members];
        }
        else {
            if (completion) {
                _finishedDeleting = completion;
            }
            
            [self getAllPreviousMembersFromUserAndDeleteMissing];
        }
    });
    
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
    [self resetEndTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _endTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                     target:self
                                                   selector:@selector(timerEnded)
                                                   userInfo:nil
                                                    repeats:NO];
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSVirtualEntourageManagerTimerDidStart object:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

- (void)timerEnded {
    
    [self resetEndTimer];
    [[NSNotificationCenter defaultCenter] postNotificationName:TSVirtualEntourageManagerTimerDidEnd object:nil];
}

- (void)resetEndTimer {
    
    [_endTimer invalidate];
    _endTimer = nil;
    
}

- (void)recalculateEntourageTimerETA {
    
    [_routeManager calculateETAForSelectedDestination:^(NSTimeInterval expectedTravelTime) {
        [self resetTimerWithTimeInterval:expectedTravelTime];
    }];
}

#pragma mark - Add Remove Members

- (void)findMembersToDelete:(NSSet *)oldMembers newMembers:(NSSet *)newMembers{
    
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
    [self deleteEntourageMembers:filtered];
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
                if (_finishedPosting) {
                    _finishedPosting(YES);
                    _finishedPosting = nil;
                }
                [self getAllPreviousMembersFromUserAndDeleteMissing];
            }
        }];
        i++;
    }
}

- (void)deleteEntourageMembers:(NSSet *)members {
    
    for (TSJavelinAPIEntourageMember *member in members) {
        [[TSJavelinAPIClient sharedClient] removeEntourageMember:member completion:^(id responseObject, NSError *error) {
            if (!error) {
                [self deletedMember:member];
            }
            else {
                [self failedToDeletedMember:member error:error];
            }
        }];
    }
}

- (void)getAllPreviousMembersFromUserAndDeleteMissing {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] getLoggedInUser:^(TSJavelinAPIUser *user) {
        [self findMembersToDelete:[NSSet setWithArray:user.entourageMembers] newMembers:_entourageMembersPosted];
        
        if (_finishedDeleting) {
            _finishedDeleting(YES);
            _finishedDeleting = nil;
        }
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

@end
