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

static NSString * const TSVirtualEntourageManagerMembersPosted = @"TSVirtualEntourageManagerMembersPosted";

NSString * const TSVirtualEntourageManagerTimerDidStart = @"TSVirtualEntourageManagerTimerDidStart";
NSString * const TSVirtualEntourageManagerTimerDidEnd = @"TSVirtualEntourageManagerTimerDidStart";

@interface TSVirtualEntourageManager ()

@property (strong, nonatomic) TSHomeViewController *homeView;
@property (strong, nonatomic) NSTimer *endTimer;

@property (nonatomic, strong) NSMutableSet *entourageMembersPosted;

@end

@implementation TSVirtualEntourageManager

- (instancetype)initWithHomeView:(TSHomeViewController *)homeView
{
    self = [super init];
    if (self) {
        _isEnabled = NO;
        self.homeView = homeView;
        self.routeManager = [[TSRouteManager alloc] initWithMapView:homeView.mapView];
        self.entourageMembersPosted = [TSVirtualEntourageManager unArchiveEntourageMembersPosted];
    }
    return self;
}


- (void)startEntourageWithMembers:(NSSet *)members {
    
    [self findMembersToDelete:members];
    [self postEntourageMembers:members];
    
    [self resetTimerWithTimeInterval:_selectedETA];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSVirtualEntourageManagerTimerDidStart object:[NSDate dateWithTimeIntervalSinceNow:_selectedETA]];
}

- (void)timerEnded {
    _isEnabled = NO;
    
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

- (void)findMembersToDelete:(NSSet *)newMembers {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        TSJavelinAPIEntourageMember *sortingMember = (TSJavelinAPIEntourageMember *)evaluatedObject;
        for (TSJavelinAPIEntourageMember *member in newMembers) {
            if (sortingMember.identifier == member.identifier) {
                return NO;
            }
        }
        
        return YES;
    }];
    
    NSSet *filtered = [_entourageMembersPosted filteredSetUsingPredicate:predicate];
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
}

- (void)deletedMember:(TSJavelinAPIEntourageMember *)member {
    
    [_entourageMembersPosted removeObject:member];
}


- (void)failedToPostMember:(TSJavelinAPIEntourageMember *)member error:(NSError *)error {
    
    NSLog(@"failedToPostMember:%@", member.name);
}

- (void)failedToDeletedMember:(TSJavelinAPIEntourageMember *)member error:(NSError *)error{
    
    NSLog(@"failedToDeleteMember:%@ id:%i", member.name, member.identifier);
    
    if (error.code == NSURLErrorBadServerResponse) {
        [self deletedMember:member];
    }
}

#pragma mark Network Requests

- (void)postEntourageMembers:(NSSet *)members {
    
    for (TSJavelinAPIEntourageMember *member in members) {
        
        [[TSJavelinAPIClient sharedClient] addEntourageMember:member completion:^(id responseObject, NSError *error) {
            if (!error) {
                [self postedMember:member];
            }
            else {
                [self failedToPostMember:member error:error];
            }
        }];
    }
}

- (void)deleteEntourageMembers:(NSSet *)members {
    
    for (TSJavelinAPIEntourageMember *member in members) {
        [[TSJavelinAPIClient sharedClient] removeEntourageMember:member completion:^(id responseObject, NSError *error) {
            if (!error) {
                
            }
            else {
                [self failedToDeletedMember:member error:error];
            }
        }];
    }
}

#pragma mark Archive Members

- (void)archiveEntourageMembersPosted {
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_entourageMembersPosted];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:TSVirtualEntourageManagerMembersPosted];
}

+ (NSMutableSet *)unArchiveEntourageMembersPosted {
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:TSVirtualEntourageManagerMembersPosted];
    return [[NSMutableSet alloc] initWithSet:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
}

@end
