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

extern NSString * const kAlertWindowAnimationTypeDown;
extern NSString * const kAlertWindowAnimationTypeZoom;

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

@interface TSAlertManager : NSObject <TCConnectionDelegate, TCDeviceDelegate>

extern NSString * const kAlertSend;
extern NSString * const kAlertSending;
extern NSString * const kAlertSent;
extern NSString * const kAlertReceived;
extern NSString * const kAlertOutsideGeofence;
extern NSString * const kAlertClosedDispatchCenter;
extern NSString * const kAlertNoConnection;

@property (nonatomic, weak) id <TSAlertDelegate> alertDelegate;
@property (nonatomic, weak) id <TSCallDelegate> callDelegate;

//Alert
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSDate *endDate;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, strong) NSString *status;
@property (assign, nonatomic) BOOL isAlertInProgress;
@property (assign, nonatomic) BOOL isPresented;

//Call
@property (strong, nonatomic) NSString *callToken;
@property (strong, nonatomic) TCDevice *twilioDevice;
@property (strong, nonatomic) TCConnection *twilioConnection;
@property (strong, nonatomic) NSDate *callStartTime;
@property (nonatomic, assign) BOOL callInProgress;



+ (instancetype)sharedManager;

- (void)startAlertCountdown:(int)seconds type:(NSString *)type;
- (void)sendAlert:(NSString *)type;
- (void)disarmAlert;

- (void)startTwilioCall;
- (void)endTwilioCall;
- (BOOL)updateAudioRoute:(BOOL)enabled;

- (void)showAlertWindowAndStartCountdownWithType:(NSString *)type currentHomeView:(TSHomeViewController *)homeViewController;
- (void)showAlertWindowForChatWithCurrentHomeView:(TSHomeViewController *)homeViewController;
- (void)setCurrentHomeViewController:(TSHomeViewController *)viewController;

- (void)callSecondary;

- (void)dismissWindowWithAnimationType:(NSString *)type completion:(void (^)(BOOL finished))completion;

@end
