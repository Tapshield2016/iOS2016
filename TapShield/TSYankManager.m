//
//  TSYankManager.m
//  TapShield
//
//  Created by Adam Share on 4/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSYankManager.h"
#import "TSBaseLabel.h"
#import "TSLocalNotification.h"
#import <AVFoundation/AVFoundation.h>

NSString * const TSYankManagerShouldShowWarningDetails = @"TSYankManagerShowWarningDetails";
NSString * const TSYankManagerSettingAutoEnableYank = @"TSYankManagerSettingAutoEnableYank";
NSString * const TSYankManagerDidYankHeadphonesNotification = @"TSYankManagerDidYankHeadphonesNotification";

static NSString * const kHeadphonesIn = @"Headphones inserted.\nYank is enabled.";
static NSString * const kInsertHeadphones = @"Insert headphone jack\nto enable Yank.";
static NSString * const kRemoveHeadphones = @"Yank is disabled.\nRemove headphones";

@interface TSYankManager ()

@property (assign, nonatomic) BOOL shouldEnable;
@property (strong, nonatomic) TSYankManagerYankEnabled yankEnabledBlock;
@property (strong, nonatomic) UIWindow *yankWindow;
@property (strong, nonatomic) TSBaseLabel *windowMessage;

@end

@implementation TSYankManager

static TSYankManager *_sharedYankManagerInstance = nil;
static dispatch_once_t predicate;

+ (instancetype)sharedYankManager {
    
    if (_sharedYankManagerInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedYankManagerInstance = [[self alloc] init];
        });
    }
    return _sharedYankManagerInstance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [AVAudioSession sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:TSYankManagerSettingAutoEnableYank] && [TSYankManager isHeadsetPluggedIn]) {
            self.isEnabled = YES;
        }
    }
    return self;
}

#pragma mark - Yank


- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    
    NSDictionary *interruptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interruptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:TSYankManagerSettingAutoEnableYank]) {
        _shouldEnable = YES;
    }
    
    [TSYankManager isHeadsetPluggedIn];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"Headphone/Line plugged in");
            
            if (_shouldEnable && [TSYankManager isHeadsetPluggedIn]) {
                self.isEnabled = YES;
            }
            
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"Headphone/Line was pulled");
            
            if (_isEnabled && ![TSYankManager isHeadsetPluggedIn]) {
                NSLog(@"Yank notification posted");
                
                [self postYankAlertNotification];
            }
            
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            
            
            break;
    }
}

+ (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    
    BOOL headphonesLocated = NO;
    for( AVAudioSessionPortDescription *portDescription in route.outputs ) {
        headphonesLocated |= ( [portDescription.portType isEqualToString:AVAudioSessionPortHeadphones] );
    }
    return headphonesLocated;
}

- (void)postYankAlertNotification {
    
    _isEnabled = NO;
    _shouldEnable = NO;
    [TSLocalNotification presentLocalNotification:@"Yank alert countdown activated!"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TSYankManagerDidYankHeadphonesNotification object:@"T"];
#warning Eventually Yank = @"Y"
}

#pragma mark - Enable/Disable Yank

- (void)setIsEnabled:(BOOL)isEnabled {
    
    _isEnabled = isEnabled;
    
    _shouldEnable = NO;
    
    if (_yankEnabledBlock) {
        _yankEnabledBlock(isEnabled);
        _yankEnabledBlock = nil;
    }
    
    if (!_yankWindow) {
        [self showInputHeadphonesWindow];
    }
    
    if (isEnabled) {
        NSLog(@"Yank enabled");
        [_windowMessage setText:kHeadphonesIn withAnimationType:kCATransitionReveal direction:kCATransitionFromBottom duration:0.3];
    }
    else {
        NSLog(@"Yank disabled");
        [_windowMessage setText:kRemoveHeadphones withAnimationType:kCATransitionReveal direction:kCATransitionFromBottom duration:0.3];
    }
    
    [self performSelector:@selector(hideYankWindow) withObject:nil afterDelay:3.0];
}


- (void)enableYank:(TSYankManagerYankEnabled)completion {
    
    if (completion) {
        _yankEnabledBlock = completion;
    }
    
    if (_isEnabled) {
        self.isEnabled = NO;
        return;
    }
    
    _shouldEnable = YES;
    
    if ([TSYankManager isHeadsetPluggedIn]) {
        self.isEnabled = YES;
    }
    else {
        [self showInputHeadphonesWindow];
    }
}

- (void)disableYank {
    
    self.isEnabled = NO;
}


#pragma mark - Yank UI

- (void)showInputHeadphonesWindow {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideYankWindow)];
    
    CGRect frame = CGRectMake(0.0f, 0.0f, 260, 140);
    _yankWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _yankWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _yankWindow.alpha = 0.0f;
    [_yankWindow addGestureRecognizer:tap];
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.center = _yankWindow.center;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:frame];
    toolbar.barStyle = UIBarStyleBlack;
    [view addSubview:toolbar];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert_yank_icon"]];
    imageView.contentMode = UIViewContentModeCenter;
    
    float centerOffsetX = frame.size.width - imageView.frame.size.width;
    imageView.center = CGPointMake((frame.size.width+centerOffsetX)/2, frame.size.height/4 + 10);
    [view addSubview:imageView];
    
    float inset = 10;
    _windowMessage = [[TSBaseLabel alloc] initWithFrame:CGRectMake(inset, frame.size.height/2, frame.size.width - inset*2, frame.size.height/2)];
    _windowMessage.numberOfLines = 0;
    _windowMessage.backgroundColor = [UIColor clearColor];
    _windowMessage.text = kInsertHeadphones;
    _windowMessage.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:17.0f];
    _windowMessage.textColor = [UIColor whiteColor];
    _windowMessage.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:_windowMessage];
    
    [_yankWindow addSubview:view];
    [_yankWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:0.3f animations:^{
        _yankWindow.alpha = 1.0f;
        view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:nil];
}

- (void)hideYankWindow {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    _shouldEnable = NO;
    _yankEnabledBlock = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            _yankWindow.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _yankWindow = nil;
            _windowMessage = nil;
        }];
    });
}

@end
