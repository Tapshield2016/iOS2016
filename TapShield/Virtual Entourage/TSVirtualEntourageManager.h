//
//  TSVirtualEntourageManager.h
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSRouteManager.h"
#import "TSPopUpWindow.h"

extern NSString * const TSVirtualEntourageManagerTimerDidStart;
extern NSString * const TSVirtualEntourageManagerTimerDidEnd;

typedef void(^TSVirtualEntourageManagerPostCompletion)(BOOL finished);

@interface TSVirtualEntourageManager : NSObject <TSPopUpWindowDelegate>

+ (instancetype)initSharedEntourageManagerWithHomeView:(id)homeView;
+ (instancetype)sharedManager;
- (instancetype)initWithHomeView:(id)homeView;

- (void)startEntourageWithMembers:(NSSet *)members ETA:(NSTimeInterval)eta completion:(TSVirtualEntourageManagerPostCompletion)completion;
- (void)stopEntourage;
- (void)manuallyEndTracking;
- (void)recalculateEntourageTimerETA;
- (void)checkRegion:(CLLocation *)userLocation;

- (void)failedToArriveAtDestination;


- (void)removeHomeViewController;

@property (nonatomic, strong) TSRouteManager *routeManager;

@property (strong, nonatomic) NSTimer *endTimer;

@property (nonatomic, assign) NSTimeInterval selectedETA;

@property (nonatomic, strong) NSArray *endRegions;

@property (readonly) BOOL isEnabled;

@property (nonatomic, strong) TSVirtualEntourageManagerPostCompletion finishedPosting;

@property (nonatomic, strong) TSVirtualEntourageManagerPostCompletion finishedDeleting;

#pragma mark - Entourage Members

@property (nonatomic, strong) NSArray *membersWhoAdded;

@end
