//
//  TSRecordWindow.h
//  TapShield
//
//  Created by Adam Share on 6/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseLabel.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+HTML.h"

@protocol TSRecordWindowDelegate <NSObject>

@optional
- (void)didDismissWindow:(UIWindow *)window audioFile:(NSURL *)filePath ;

@end

@interface TSRecordWindow : UIWindow <AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id <TSRecordWindowDelegate> recordDelegate;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

- (void)show;
- (void)dismiss:(NSURL *)audioUrl;

@end
