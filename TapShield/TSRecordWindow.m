//
//  TSRecordWindow.m
//  TapShield
//
//  Created by Adam Share on 6/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRecordWindow.h"
#import "NSDate+Utilities.h"
#import "TSCircularButton.h"
#import "TSUtilities.h"

#define kRecordButtonSize 50

static NSString * const kRecordButtonName = @"Record_Button";
static NSString * const kPauseButtonName = @"Stop_Record_Button";

@interface TSRecordWindow ()

@property (strong, nonatomic) UIView *view;
@property (assign, nonatomic) CGRect viewFrame;
@property (strong, nonatomic) TSBaseLabel *label;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) NSTimer *timer;

@end


@implementation TSRecordWindow

- (id)init {
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Initialization code
        [self windowView];
        [self addAudioButtons];
        [self addTimerLabel];
        [self initRecorder];
    }
    return self;
}

- (void)initRecorder {
    
    NSURL *soundFileURL = [self soundFileURLForName:@"temp"];
    
    NSDictionary *recordSettings = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                     AVEncoderAudioQualityKey: @(AVAudioQualityMin),
                                     AVSampleRateKey: @16000.0,
                                     AVNumberOfChannelsKey: @1};
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord
                        error:nil];
    [audioSession setActive:YES error:nil];
    
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL
                                                 settings:recordSettings
                                                    error:&error];
    _audioRecorder.delegate = self;
    
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    else {
        [_audioRecorder prepareToRecord];
    }
}

- (void)windowView {
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.alpha = 0.0f;
    self.windowLevel = UIWindowLevelAlert;
    
    _viewFrame = CGRectMake(0.0f, 0.0f, 260, 150);
    
    _view = [[UIView alloc] initWithFrame:_viewFrame];
    _view.center = self.center;
    _view.layer.cornerRadius = 10;
    _view.layer.masksToBounds = YES;
    _view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    _toolbar = [[UIToolbar alloc] initWithFrame:_viewFrame];
    _toolbar.barStyle = UIBarStyleBlack;
    [_view addSubview:_toolbar];
    
    [self addSubview:_view];
    
    [self dismissButton];
}

- (void)dismissButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(_viewFrame.size.width/2 +kRecordButtonSize/2, _viewFrame.size.height/2, _viewFrame.size.width/2 - kRecordButtonSize/2, _viewFrame.size.height/2);
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    [_view addSubview:button];
}

- (void)addAudioButtons {
    
    _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_recordButton addTarget:self action:@selector(recordPause) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton setBackgroundImage:[UIImage imageNamed:kRecordButtonName] forState:UIControlStateNormal];
    [_recordButton setBackgroundImage:[UIImage imageNamed:kPauseButtonName] forState:UIControlStateSelected];
    _recordButton.frame = CGRectMake(0, 0, kRecordButtonSize, kRecordButtonSize);
    _recordButton.center = CGPointMake(_viewFrame.size.width/2, _viewFrame.size.height*.75);
    [_view addSubview:_recordButton];
}

- (void)addTimerLabel {
    
    _label = [[TSBaseLabel alloc] initWithFrame:CGRectMake(0, 0, _viewFrame.size.width, _viewFrame.size.height/2)];
    _label.numberOfLines = 1;
    _label.backgroundColor = [UIColor clearColor];
    _label.text = @"00:00.00";
    _label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:45.0f];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    
    [_view addSubview:_label];
}

#pragma mark - Recording

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    
}


- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    [recorder pause];
    _recordButton.selected = NO;
    [self stopTimer];
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags {
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    
}

- (void)recordPause {
    
    _recordButton.selected = !_recordButton.selected;
    
    if (_recordButton.selected) {
        [self startRecording];
    }
    else {
        [self pauseRecording];
    }
}

- (void)startRecording {
    
    if (!_audioRecorder.recording) {
        [_audioRecorder record];
        [self startTimer];
    }
}

- (void)pauseRecording {
    [_audioRecorder pause];
    [self stopTimer];
}

- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(adjustTime) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    
    [_timer invalidate];
    _timer = nil;
}

- (void)adjustTime {
    _label.text = [TSUtilities formattedStringForTimeWithMs:_audioRecorder.currentTime];
}

- (void)cancel {
    
    if (_audioRecorder.currentTime == 0) {
        [_audioRecorder stop];
        [_audioRecorder deleteRecording];
        [self dismiss:nil];
    }
    else {
        [self showAlertViewToSave];
    }
}

#pragma mark - Save or Delete 

- (void)showAlertViewToSave {
    
    [_audioRecorder stop];
    
    self.windowLevel = UIWindowLevelNormal;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Recording"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Delete"
                                             otherButtonTitles:@"Save", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setPlaceholder:[NSDate fileDateTimeNowString]];
    [textField setText:[NSDate fileDateTimeNowString]];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setKeyboardType:UIKeyboardTypeASCIICapable];
    [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [textField setDelegate:self];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [_audioRecorder deleteRecording];
        [self dismiss:nil];
    }
    else if (buttonIndex == 1) {
        NSString *string = [alertView textFieldAtIndex:0].text;
        if (!string || !string.length) {
            string = [NSDate fileDateTimeNowString];
        }
        NSURL *newUrl = [self soundFileURLForName:string];
        NSURL *oldUrl = [self soundFileURLForName:@"temp"];
        
        NSError *error;
        [[NSFileManager defaultManager] moveItemAtURL:oldUrl toURL:newUrl error:&error];
        if (error) {
            newUrl = oldUrl;
        }
        [self dismiss:newUrl];
    }
}

#pragma mark - Show/Hide Window

- (void)show {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self makeKeyAndVisible];
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:300.0
              initialSpringVelocity:5.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            self.alpha = 1.0f;
            _view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    });
}

- (void)dismiss:(NSURL *)audioURL  {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self setHidden:YES];
            [self removeFromSuperview];
            
            if ([_recordDelegate respondsToSelector:@selector(didDismissWindow:audioFile:)]) {
                [_recordDelegate didDismissWindow:self audioFile:audioURL];
            }
        }];
    });
}

- (NSURL *)soundFileURLForName:(NSString *)name {
    
    name = [name encodeStringForURLPath];
    
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *newFolderPath = [documentsDirectory stringByAppendingPathComponent:@"/recorded"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:newFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSString *fileName = [NSString stringWithFormat:@"/recorded/%@%@", name, @".aac"];
    NSString *soundFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    return [NSURL fileURLWithPath:soundFilePath];
}

@end
