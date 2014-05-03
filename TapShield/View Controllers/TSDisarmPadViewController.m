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

@property (strong, nonatomic) TSPageViewController *pageViewController;

@end

@implementation TSDisarmPadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    _codeCircleArray = @[_codeCircle1, _codeCircle2, _codeCircle3, _codeCircle4];
    
    _disarmTextField.text = @"";
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
    
}

- (void)setSuperviewViewController:(UIViewController *)superviewViewController {
    
    _superviewViewController = superviewViewController;
    
    if ([superviewViewController isKindOfClass:[TSPageViewController class]]) {
        _pageViewController = (TSPageViewController *)superviewViewController;
    }
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
        [_pageViewController.emergencyAlertViewController.sendEmergencyTimer invalidate];
        [_pageViewController.emergencyAlertViewController endCall];
        [[TSJavelinAPIClient sharedClient] disarmAlert];
        [[TSJavelinAPIClient sharedClient] cancelAlert];
        
        [_pageViewController.toolbar setTranslucent:NO];
        [_pageViewController.toolbar setAlpha:0.5f];
        [_pageViewController.homeViewController viewWillAppear:NO];
        [_pageViewController.homeViewController viewDidAppear:NO];
        [_pageViewController.homeViewController whiteNavigationBar];
        [_pageViewController dismissViewControllerAnimated:YES completion:nil];
        
        if (_pageViewController.homeViewController.entourageManager.isEnabled &&
            !_pageViewController.homeViewController.entourageManager.endTimer) {
            [_pageViewController.homeViewController.entourageManager recalculateEntourageTimerETA];
        }
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
