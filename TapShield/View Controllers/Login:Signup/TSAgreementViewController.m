//
//  TSAgreementViewController.m
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAgreementViewController.h"

@interface TSAgreementViewController ()

@end

@implementation TSAgreementViewController

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
    [_agreeButton setBackgroundImage:[UIImage imageFromColor:[TSColorPalette tapshieldDarkBlue]] forState:UIControlStateNormal];
    [_agreeButton setBackgroundImage:[UIImage imageHighlightedFromColor:[TSColorPalette tapshieldDarkBlue]] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
