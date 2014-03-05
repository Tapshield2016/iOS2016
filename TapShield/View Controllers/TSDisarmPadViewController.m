//
//  TSDisarmPadViewController.m
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSDisarmPadViewController.h"

@interface TSDisarmPadViewController ()

@end

@implementation TSDisarmPadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    _sendEmergencyTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                           target:self
                                                         selector:@selector(sendEmergency:)
                                                         userInfo:nil
                                                          repeats:NO];
    
    [UIView animateWithDuration:10.0f animations:^{
        _countdownTintView.frame = self.view.frame;
    }];
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

- (IBAction)sendEmergency:(id)sender {
    
    [[TSLocationController sharedLocationController] latestLocation:^(CLLocation *location) {
        [[TSJavelinAPIClient sharedClient] sendEmergencyAlertWithAlertType:@"E" location:location completion:^(BOOL success) {
            if (success) {
                
            }
            else {
                
            }
        }];
    }];

    
}

- (void)checkDisarmCode {
    
    if (_disarmTextField.text.length != 4) {
        return;
    }
    
    if ([_disarmTextField.text isEqualToString:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode]) {
        [_sendEmergencyTimer invalidate];
        [[TSJavelinAPIClient sharedClient] disarmAlert];
        [[TSJavelinAPIClient sharedClient] cancelAlert];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else {
        [self shakeDisarmCircles];
        _disarmTextField.text = @"";
        [self performSelector:@selector(selectCodeCircles) withObject:nil afterDelay:0.08 * 6];
    }
}

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
