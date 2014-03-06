//
//  TSDisarmPadViewController.m
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSDisarmPadViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TSDisarmPadViewController ()

@end

@implementation TSDisarmPadViewController

+ (void)presentFromViewController:(UIViewController *)presentingController transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate {
    
    TSDisarmPadViewController *disarmPad = [[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"TSDisarmPadViewController"];
    
    [presentingController.navigationController setNavigationBarHidden:YES animated:YES];
    [presentingController.navigationController setToolbarHidden:YES animated:YES];
    
    [disarmPad setTransitioningDelegate:delegate];
    disarmPad.modalPresentationStyle = UIModalPresentationCustom;
    [presentingController presentViewController:disarmPad animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _codeCircleArray = @[_codeCircle1, _codeCircle2, _codeCircle3, _codeCircle4];
    
    _disarmTextField.text = @"";
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:toolbar atIndex:0];
    
    _countdownTintView = [[UIView alloc] initWithFrame:self.view.bounds];
    CGRect frame = _countdownTintView.frame;
    frame.origin.y = self.view.frame.size.height - 1.0f;
    _countdownTintView.frame = frame;
    _countdownTintView.backgroundColor = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.6];
    [self.view insertSubview:_countdownTintView atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self scheduleSendEmergencyTimer];
    
    [UIView animateWithDuration:10.0f animations:^{
        _countdownTintView.frame = self.view.frame;
        _countdownTintView.backgroundColor = [TSColorPalette colorWithRed:255/255 green:153/255 blue:153/255 alpha:0.2f];
    }];
}


#pragma mark - Emergency Alert

- (void)scheduleSendEmergencyTimer {
    
    if ([[TSJavelinAPIClient sharedClient] alertManager].activeAlert) {
        _emergencyButton.hidden = YES;
        return;
    }
    
    _sendEmergencyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                           target:self
                                                         selector:@selector(emergencyTimerCountdown:)
                                                         userInfo:[NSDate date]
                                                          repeats:YES];
}

- (void)emergencyTimerCountdown:(NSTimer *)timer {
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    if ([(NSDate *)timer.userInfo timeIntervalSinceNow] <= -10) {
        [_sendEmergencyTimer invalidate];
        [self performSelector:@selector(sendEmergency:) withObject:timer];
    }
}

- (IBAction)sendEmergency:(id)sender {
    
    [[TSLocationController sharedLocationController] latestLocation:^(CLLocation *location) {
        [[TSJavelinAPIClient sharedClient] sendEmergencyAlertWithAlertType:@"E" location:location completion:^(BOOL success) {
            if (success) {
                
            }
            else {
                
            }
        }];
    }];

    [self performSelectorOnMainThread:@selector(stopTintViewAmination) withObject:nil waitUntilDone:NO];
}

#pragma mark - Disarm Code

- (IBAction)numberPressed:(id)sender {
    
    if (_disarmTextField.text) {
        _disarmTextField.text = [NSString stringWithFormat:@"%@%@", _disarmTextField.text, ((UIButton *)sender).titleLabel.text];
    }
    else {
        _disarmTextField.text = ((UIButton *)sender).titleLabel.text;
    }
    
    [self selectCodeCircles];
    
    [self checkDisarmCode];
}

- (IBAction)clearDisarmText:(id)sender {
    _disarmTextField.text = @"";
    
    [self selectCodeCircles];
}

- (void)selectCodeCircles {
    int i = 1;
    for (TSNumberPadButton *circle in _codeCircleArray) {
        
        if (_disarmTextField.text.length < i) {
            circle.selected = NO;
        }
        else {
            circle.selected = YES;
        }
        i++;
    }
}

- (void)checkDisarmCode {
    
    if (_disarmTextField.text.length != 4) {
        return;
    }
    
    if ([_disarmTextField.text isEqualToString:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode]) {
        [_sendEmergencyTimer invalidate];
        [[TSJavelinAPIClient sharedClient] disarmAlert];
        [[TSJavelinAPIClient sharedClient] cancelAlert];
        
        UINavigationController *parentNavigationController;
        if ([[self.presentingViewController.childViewControllers firstObject] isKindOfClass:[UINavigationController class]]) {
            parentNavigationController = (UINavigationController *)[self.presentingViewController.childViewControllers firstObject];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            [parentNavigationController setToolbarHidden:NO animated:YES];
            [parentNavigationController setNavigationBarHidden:NO animated:YES];
        }];
    }
    else {
        [self shakeDisarmCircles];
        _disarmTextField.text = @"";
        [self performSelector:@selector(selectCodeCircles) withObject:nil afterDelay:0.08 * 6];
    }
}

#pragma mark - Animations

- (void)shakeDisarmCircles {
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.08f];
    [animation setRepeatCount:3.0f];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([_codeCircleContainerView center].x - 20.0f, [_codeCircleContainerView center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([_codeCircleContainerView center].x + 20.0f, [_codeCircleContainerView center].y)]];
    [[_codeCircleContainerView layer] addAnimation:animation forKey:@"position"];
}

- (void)stopTintViewAmination {
    
    [_countdownTintView.layer removeAllAnimations];
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _countdownTintView.frame = self.view.frame;
                         _countdownTintView.backgroundColor = [TSColorPalette colorWithRed:255/255 green:153/255 blue:153/255 alpha:0.2f];
                         _emergencyButton.alpha = 0.0f;
                     } completion:nil];
}


@end
