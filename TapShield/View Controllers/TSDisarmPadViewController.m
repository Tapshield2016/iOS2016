//
//  TSDisarmPadViewController.m
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSDisarmPadViewController.h"
#import "TSPageViewController.h"

@interface TSDisarmPadViewController ()

@end

@implementation TSDisarmPadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    _codeCircleArray = @[_codeCircle1, _codeCircle2, _codeCircle3, _codeCircle4];
    
    _disarmTextField.text = @"";
    
//    _swipeViewController = [[TSGradientSwipeViewController alloc] initWithTitleText:@"send alert"];
//    _swipeViewController.view.frame = _swipeLabelView.bounds;
//    _swipeViewController.label.frame = _swipeLabelView.bounds;
//    _swipeViewController.imageView.frame = _swipeLabelView.bounds;
//    [_swipeLabelView addSubview:_swipeViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self scheduleSendEmergencyTimer];
}

#pragma mark - Emergency Alert

- (void)scheduleSendEmergencyTimer {
    
    if ([[TSJavelinAPIClient sharedClient] alertManager].activeAlert) {
        _emergencyButton.hidden = YES;
        return;
    }
    
    if (!_sendEmergencyTimer) {
        _sendEmergencyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                               target:self
                                                             selector:@selector(emergencyTimerCountdown:)
                                                             userInfo:[NSDate date]
                                                              repeats:YES];
    }
}

- (void)emergencyTimerCountdown:(NSTimer *)timer {
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    if ([(NSDate *)timer.userInfo timeIntervalSinceNow] <= -10) {
        [_sendEmergencyTimer invalidate];
        [self performSelector:@selector(sendEmergency:) withObject:timer];
    }
}

- (IBAction)sendEmergency:(id)sender {
    
    [(TSPageViewController *)self.parentViewController showAlertScreen];
    
    _isSendingAlert = YES;
    
    [[TSLocationController sharedLocationController] latestLocation:^(CLLocation *location) {
        [[TSJavelinAPIClient sharedClient] sendEmergencyAlertWithAlertType:@"E" location:location completion:^(BOOL success) {
            if (success) {
                
            }
            else {
                
            }
        }];
    }];
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

- (IBAction)deleteDisarmText:(id)sender {
    
    if ([_disarmTextField.text length] > 0) {
        _disarmTextField.text = [_disarmTextField.text substringToIndex:_disarmTextField.text.length - 1];
    }
    
    [self selectCodeCircles];
}

- (void)selectCodeCircles {
    int i = 1;
    for (TSCircularButton *circle in _codeCircleArray) {
        
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
        
        [((TSPageViewController *)self.parentViewController).toolbar setTranslucent:NO];
        [((TSPageViewController *)self.parentViewController).toolbar setAlpha:0.5f];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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




@end
