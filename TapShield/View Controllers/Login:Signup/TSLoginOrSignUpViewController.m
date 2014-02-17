//
//  TSLoginOrSignUpViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSLoginOrSignUpViewController.h"

@interface TSLoginOrSignUpViewController ()

@end

@implementation TSLoginOrSignUpViewController

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
    [_loginButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:[UIImage imageHighlightedFromColor:[TSColorPalette tapshieldBlue]] forState:UIControlStateHighlighted];
    [_signUpButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldDarkBlue]] forState:UIControlStateNormal];
    [_signUpButton setBackgroundImage:[UIImage imageHighlightedFromColor:[TSColorPalette tapshieldDarkBlue]] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
