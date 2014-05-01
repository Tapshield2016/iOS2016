//
//  TSForgotPasswordViewController.m
//  TapShield
//
//  Created by Adam Share on 5/1/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSForgotPasswordViewController.h"

@interface TSForgotPasswordViewController ()

@end

@implementation TSForgotPasswordViewController

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
    
    _emailTextField.text = _email;
    
    [self addBottomButtons];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBottomButtons {
    
    TSBaseButton *leftButton = [self buttonWithTitle:@"Log in" selector:@selector(backToLogin:)];
    TSBaseButton *rightButton = [self buttonWithTitle:@"Sign up" selector:@selector(backToSignUp:)];
    
    CGRect frame = rightButton.frame;
    frame.origin.x = _scrollView.frame.size.width - frame.size.width - 20;
    rightButton.frame = frame;
    
    frame = leftButton.frame;
    frame.origin.x = 20;
    leftButton.frame = frame;
    
    [_scrollView addSubview:leftButton];
    [_scrollView addSubview:rightButton];
    _scrollView.contentSize = [UIScreen mainScreen].bounds.size;
}

- (TSBaseButton *)buttonWithTitle:(NSString *)name selector:(SEL)selector {
    
    TSBaseButton *button = [[TSBaseButton alloc] initWithFrame:CGRectZero fontSize:17];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:name forState:UIControlStateNormal];
    [button sizeToFit];
    
    CGRect frame = button.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - 1.25*frame.size.height;
    button.frame = frame;
    
    return button;
}

- (IBAction)backToLogin:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backToSignUp:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
