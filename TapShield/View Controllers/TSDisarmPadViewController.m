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
@property (assign, nonatomic) NSUInteger failAttempts;

@end

@implementation TSDisarmPadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _failAttempts = 0;
    
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
        [self disarm];
    }
    else {
        _failAttempts++;
        [self shakeDisarmCircles];
        _disarmTextField.text = @"";
        [self performSelector:@selector(selectCodeCircles) withObject:nil afterDelay:0.08 * 4];
        
        if (_failAttempts > 4) {
            [self disarmViaPassword];
        }
    }
}

- (void)disarmViaPassword {
    
    
    
}

- (void)disarm {
    [[TSAlertManager sharedManager] disarmAlert];
    [[TSJavelinAPIClient sharedClient] disarmAlert];
    [[TSJavelinAPIClient sharedClient] cancelAlert];
    
    [_pageViewController.homeViewController mapAlertModeToggle];
    [_pageViewController.toolbar setTranslucent:NO];
    [_pageViewController.toolbar setAlpha:0.5f];
    [_pageViewController.homeViewController viewWillAppear:NO];
    [_pageViewController.homeViewController viewDidAppear:NO];
    [_pageViewController.homeViewController whiteNavigationBar];
    [_pageViewController dismissViewControllerAnimated:YES completion:nil];
    
    if ([TSVirtualEntourageManager sharedManager].isEnabled &&
        ![TSVirtualEntourageManager sharedManager].endTimer) {
        [[TSVirtualEntourageManager sharedManager] recalculateEntourageTimerETA];
    }
}

#pragma mark - Animations

- (void)shakeDisarmCircles {
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.08f];
    [animation setRepeatCount:2.0f];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([_codeCircleContainerView center].x - 20.0f, [_codeCircleContainerView center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([_codeCircleContainerView center].x + 20.0f, [_codeCircleContainerView center].y)]];
    [[_codeCircleContainerView layer] addAnimation:animation forKey:@"position"];
}




@end
