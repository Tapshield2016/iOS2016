//
//  TSEntourageSessionManager.h
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSRouteManager.h"
#import "TSPopUpWindow.h"
#import "TSEntourageMemberAnnotation.h"

@class TSHomeViewController;

extern NSString * const TSEntourageSessionManagerTimerDidStart;
extern NSString * const TSEntourageSessionManagerTimerDidEnd;

typedef void(^TSEntourageSessionManagerPostCompletion)(BOOL finished);

@interface TSEntourageSessionManager : NSObject <TSPopUpWindowDelegate>

+ (instancetype)initSharedEntourageManagerWithHomeView:(id)homeView;
+ (instancetype)sharedManager;
- (instancetype)initWithHomeView:(id)homeView;

- (void)startEntourageWithMembers:(NSSet *)members ETA:(NSTimeInterval)eta completion:(TSEntourageSessionManagerPostCompletion)completion;
- (void)stopEntourage;
- (void)manuallyEndTracking;
- (void)recalculateEntourageTimerETA;
- (void)checkRegion:(CLLocation *)userLocation;

- (void)failedToArriveAtDestination;

- (void)removeHomeViewController;

- (void)locateEntourageMember:(TSJavelinAPIEntourageMember *)member;

@property (nonatomic, strong) TSRouteManager *routeManager;

@property (weak, nonatomic) TSHomeViewController *homeView;

@property (strong, nonatomic) NSTimer *endTimer;

@property (nonatomic, assign) NSTimeInterval selectedETA;

@property (nonatomic, strong) NSArray *endRegions;

@property (readonly) BOOL isEnabled;

@property (nonatomic, strong) TSEntourageSessionManagerPostCompletion finishedPosting;

@property (nonatomic, strong) TSEntourageSessionManagerPostCompletion finishedDeleting;

#pragma mark - Entourage Members

- (void)getAllEntourageSessions:(void (^)(NSArray *entourageMembers))completion;

- (void)showSessionForMember:(TSJavelinAPIEntourageMember *)member;

- (void)removeCurrentMemberSession;

@end
