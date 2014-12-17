//
//  TSNotifySelectionViewController.m
//  TapShield
//
//  Created by Adam Share on 4/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNotifySelectionViewController.h"
#import "TSAddMemberCell.h"
#import "TSCircularControl.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface TSNotifySelectionViewController ()

@property (strong, nonatomic) NSTimer *clockTimer;
@property (strong, nonatomic) UIAlertController *saveChangesAlertController;
@property (assign, nonatomic) BOOL changedTime;
@property (strong, nonatomic) TSCircularControl *slider;
@property (strong, nonatomic) TSPopUpWindow *tutorialWindow;
@property (assign, nonatomic) BOOL isStarting;

@property (assign, nonatomic) BOOL showDateTime;


@property (strong, nonatomic) UIView *backView;

@end

@implementation TSNotifySelectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _changedTime = NO;
    
    _okButton.enabled = NO;
    
    [_roundedRect roundBezierPathCornerRadius:10];
    
    _insideView.layer.shadowColor = [[UIColor blackColor] CGColor];
    _insideView.layer.shadowOpacity = .6;
    _insideView.layer.shadowOffset = CGSizeZero;
    _insideView.layer.masksToBounds = NO;
    _insideView.layer.shadowRadius = 10.0f;
    
    //Create the Circular Slider
    CGRect frame = _insideView.frame;
    frame.size.height -= 44;
    _slider = [[TSCircularControl alloc]initWithFrame:frame];
    
    _estimatedTimeInterval = [TSEntourageSessionManager sharedManager].routeManager.selectedRoute.expectedTravelTime;
    
    if (_estimatedTimeInterval < 60) {
        _estimatedTimeInterval = 60;
    }
    
    if ([TSEntourageSessionManager sharedManager].isEnabled) {
        _timeAdjusted = [[TSJavelinAPIClient loggedInUser].entourageSession.eta timeIntervalSinceNow];
    }
    else {
        _timeAdjusted = [TSEntourageSessionManager sharedManager].routeManager.selectedTravelTime;
    }
    
    _timeAdjustLabel = [[TSBaseLabel alloc] initWithFrame:_slider.frame];
    _timeAdjustLabel.text = [TSUtilities formattedStringForTime:_timeAdjusted];
    _timeAdjustLabel.font = [TSFont fontWithName:kFontWeightThin size:30.0];
    _timeAdjustLabel.textAlignment = NSTextAlignmentCenter;
    _timeAdjustLabel.textColor = [UIColor whiteColor];
    
    _showDateTime = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTimeFormat)];
    tap.delegate = self;
    [_slider addGestureRecognizer:tap];
    
    //Define Target-Action behaviour
    [_slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_slider];
    [self.view addSubview:_timeAdjustLabel];
    
    if ([TSEntourageSessionManager sharedManager].isEnabled) {
        [self adjustViewableTime];
    }
    else {
        [_slider setDegreeForStartTime:_estimatedTimeInterval currentTime:_timeAdjusted];
    }
    
    _backView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _backView.alpha = 0.0;
    
    UITapGestureRecognizer *closetap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)];
    tap.delegate = self;
    [_backView addGestureRecognizer:closetap];
    [self.view insertSubview:_backView atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.3 animations:^{
        _backView.alpha = 1.0;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    _backView.hidden = YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return NO;
}

- (void)dismissViewController {
    UINavigationController *navcontroller;
    if ([TSEntourageSessionManager sharedManager].isEnabled) {
        navcontroller = (UINavigationController *)[[UIApplication sharedApplication].delegate.window.rootViewController.childViewControllers firstObject];
    }
    else {
        navcontroller = (UINavigationController *)self.presentingViewController;
    }
    
    
    [[navcontroller.childViewControllers lastObject] beginAppearanceTransition:YES animated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[navcontroller.childViewControllers lastObject] endAppearanceTransition];
    }];
}


#pragma mark - Circular Control 

/** This function is called when Circular slider value changes **/
- (void)newValue:(TSCircularControl *)slider {
    
    [self stopClockTimer];
    
    int adjustedAngle;
    if (slider.angle <= 90) {
        adjustedAngle = 90 - slider.angle;
    }
    else {
        adjustedAngle = 360 - slider.angle + 90;
    }
    
    NSTimeInterval addedTime = (int)adjustedAngle - 180;
    float timeRatio = _estimatedTimeInterval/180;
    
    addedTime = _estimatedTimeInterval + addedTime * timeRatio;
    
    _timeAdjusted = [self roundTime:(int)addedTime];
    
    if (_showDateTime) {
        _timeAdjustLabel.text = [NSDate dateWithTimeIntervalSinceNow:_timeAdjusted].shortTimeString;
    }
    else {
        _timeAdjustLabel.text = [TSUtilities formattedStringForTime:_timeAdjusted];
    }
    
    _changedTime = YES;
    _okButton.enabled = YES;
}

- (NSTimeInterval)roundTime:(NSTimeInterval)interval {
    
    if (ceil(_estimatedTimeInterval/60) <=  10) {
        return interval;
    }
    
    NSTimeInterval minutes = ceil(interval/60);
    
    if (ceil((_estimatedTimeInterval/60)/60) <=  6) {
        return minutes * 60;
    }
    
    minutes = ceil(minutes/5);
    
    return minutes * 60 * 5;
}

- (void)toggleTimeFormat {
    
    _showDateTime = !_showDateTime;
    
    if (_showDateTime) {
        _timeAdjustLabel.text = [NSDate dateWithTimeIntervalSinceNow:_timeAdjusted].shortTimeString;
    }
    else {
        _timeAdjustLabel.text = [TSUtilities formattedStringForTime:_timeAdjusted];
    }
}

- (void)adjustViewableTime {
    
    NSTimeInterval interval = 1;
    if (_estimatedTimeInterval < 360) {
        interval = .1;
    }
    
    if (!_clockTimer) {
        _clockTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                       target:self
                                                     selector:@selector(adjustViewableTime)
                                                     userInfo:nil
                                                      repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_clockTimer forMode:NSRunLoopCommonModes];
    }
    
    NSDate *fireDate = [TSEntourageSessionManager sharedManager].endTimer.fireDate;
    
    _timeAdjusted = [fireDate timeIntervalSinceDate:[NSDate date]];
    
    if (_showDateTime) {
        _timeAdjustLabel.text = fireDate.shortTimeString;
    }
    else {
        _timeAdjustLabel.text = [TSUtilities formattedStringForTime:_timeAdjusted];
    }
    
    [_slider setDegreeForStartTime:_estimatedTimeInterval currentTime:_timeAdjusted];
}

- (void)stopClockTimer {
    
    [_clockTimer invalidate];
    _clockTimer = nil;
}


- (void)didDismissWindow:(UIWindow *)window {
    
    [self dismissViewController];
}


- (void)saveWithPasscode {
    
    _saveChangesAlertController = [UIAlertController alertControllerWithTitle:@"Confirm Changes"
                                                                      message:@"Please enter passcode"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self)weakSelf = self;
    [_saveChangesAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"1234"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setSecureTextEntry:YES];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [textField setDelegate:weakSelf];
    }];
    [_saveChangesAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:_saveChangesAlertController animated:YES completion:nil];
}

- (BOOL)changesWereMade {
    
    return _changedTime;
}




#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    textField.backgroundColor = [TSColorPalette whiteColor];
    
    if ([textField.text length] + [string length] - range.length == 4) {
        textField.text = [textField.text stringByAppendingString:string];
        [self checkDisarmCode:textField];
        return NO;
    }
    else if ([textField.text length] + [string length] - range.length > 4) {
        [self checkDisarmCode:textField];
        return NO;
    }
    
    return YES;
}

- (void)checkDisarmCode:(UITextField *)textField {
    
    if (textField.text.length != 4) {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
        return;
    }
    
    if ([textField.text isEqualToString:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode]) {
        [_saveChangesAlertController dismissViewControllerAnimated:YES completion:nil];
        [self performSelector:@selector(startEntourage:) withObject:nil];
    }
    else {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
    }
}


#pragma mark - Touch ID

- (void)useTouchID {
    
    LAContext *context = [[LAContext alloc] init];
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:@"Confirm Changes"
                      reply:^(BOOL success, NSError *error) {
                          
                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                              if (error) {
                                  
                                  if (error.code == kLAErrorUserCancel ||
                                      error.code == kLAErrorSystemCancel) {
                                      
                                  }
                                  else if (error.code == kLAErrorUserFallback) {
                                      [self saveWithPasscode];
                                  }
                                  else {
                                      UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                                      [errorController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                                      [self presentViewController:errorController animated:YES completion:nil];
                                  }
                              }
                              else if (success) {
                                  [_saveChangesAlertController dismissViewControllerAnimated:YES completion:nil];
                                  [self performSelector:@selector(startEntourage:) withObject:nil];
                              }
                          }];
                      }];
}

- (BOOL)touchIDAvailable {
    
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}


- (IBAction)startEntourage:(id)sender {
    if (_isStarting) {
        return;
    }
    _isStarting = YES;
    
    [[TSEntourageSessionManager sharedManager] startTrackingWithETA:_timeAdjusted completion:nil];
    
    [self dismissViewController];
}

- (IBAction)ok:(id)sender {
    
    if ([TSEntourageSessionManager sharedManager].isEnabled && [self changesWereMade]) {
        if ([self touchIDAvailable]) {
            [self useTouchID];
        }
        else {
            [self saveWithPasscode];
        }
    }
    else {
        [TSEntourageSessionManager sharedManager].routeManager.selectedTravelTime = _timeAdjusted;
        [self dismissViewController];
    }
}

- (IBAction)cancel:(id)sender {
    
    if ([TSEntourageSessionManager sharedManager].isEnabled) {
//        [[TSEntourageSessionManager sharedManager] startStatusBarTimer];
    }
    
    [self dismissViewController];
}
@end
