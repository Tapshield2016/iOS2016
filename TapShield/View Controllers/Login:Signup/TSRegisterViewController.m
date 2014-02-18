//
//  TSRegisterViewController.m
//  TapShield
//
//  Created by Adam Share on 2/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRegisterViewController.h"

@interface TSRegisterViewController ()

@end

@implementation TSRegisterViewController

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
    _checkAgreeButton.layer.shadowColor = [UIColor grayColor].CGColor;
    _checkAgreeButton.layer.shadowOffset = CGSizeMake(0, 1);
    _checkAgreeButton.layer.shadowOpacity = 1;
    _checkAgreeButton.layer.shadowRadius = 1.0;
    _checkAgreeButton.clipsToBounds = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectAgree:(id)sender {
    _checkAgreeButton.selected = !_checkAgreeButton.selected;
}

@end
