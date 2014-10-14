//
//  TSAlertManager.h
//  TapShield
//
//  Created by Adam Share on 5/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TwilioSDK/TwilioClient.h>
#import "TSHomeViewController.h"

@import CoreTelephony;

extern NSString * const kAlertWindowAnimationTypeDown;
extern NSString * const kAlertWindowAnimationTypeZoomIn;
extern NSString * const kAlertWindowAnimationTypeZoomOut;

@protocol TSAlertDelegate <NSObject>

@optional
- (void)alertStatusChanged:(NSString *)status;
- (void)startingPhoneCall;

@end


@protocol TSCallDelegate <NSObject>

@optional
- (void)connectionDidStartConnecting:(TCConnection *)connection;
- (void)connectionDidConnect:(TCConnection *)connection;
- (void)connectionDidDisconnect:(TCConnection *)connection;
- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error;

@end

@interface TSAlertManager : NSObject <TCConnectionDelegate, TCDeviceDelegate, TSJavelinAlertManagerDelegate>

extern NSString * const kAlertSend;
extern NSString * const kAlertSending;
extern NSString * const kAlertSent;
extern NSString * const kAlertReceived;
extern NSString * const kAlertOutsideGeofence;
extern NSString * const kAlertClosedDispatchCenter;
extern NSString * const kAlertNoConnection;

extern NSString * const kAlertType911Call;
extern NSString * const kAlertTypeAlertCall;
extern NSString * const kAlertTypeEntourage;
extern NSString * const kAlertTypeYank;
extern NSString * const kAlertTypeChat;

@property (nonatomic, weak) id <TSAlertDelegate> alertDelegate;
@property (nonatomic, weak) id <TSCallDelegate> callDelegate;

@property (nonatomic, weak) TSHomeViewController *homeViewController;

//Alert
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSDate *endDate;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, strong) NSString *status;
@property (assign, nonatomic, readonly) BOOL isAlertInProgress;
@property (assign, nonatomic, readonly) BOOL isPresented;

//Call
@property (strong, nonatomic) NSString *callToken;
@property (strong, nonatomic) TCDevice *twilioDevice;
@property (strong, nonatomic) TCConnection *twilioConnection;
@property (strong, nonatomic) NSDate *callStartTime;
@property (nonatomic, assign, readonly) BOOL callInProgress;

+ (instancetype)sharedManager;

- (void)startAlertCountdown:(int)seconds type:(NSString *)type;
- (void)sendAlertType:(NSString *)type;
- (void)disarmAlert;

- (void)startTwilioCall;
- (void)endTwilioCall;
- (BOOL)updateAudioRoute:(BOOL)enabled;

- (void)callEmergencyNumber;

- (void)dismissWindowWithAnimationType:(NSString *)type completion:(void (^)(BOOL finished))completion;

- (void)showAlertWindowForChat;

- (void)startEmergencyNumberAlert;
- (void)startAgencyDispathcerCallAlert;
- (void)startChatAlert;
- (void)startYankAlertCountdown;
- (void)startEntourageAlertCountdown;

- (void)notifiedCTCallStateDialing:(CTCall *)call;
- (void)notifiedCTCallStateConnected:(CTCall *)call;
- (void)notifiedCTCallStateDisconnected:(CTCall *)call;
- (void)notifiedCTCallStateIncoming:(CTCall *)call;

@end
