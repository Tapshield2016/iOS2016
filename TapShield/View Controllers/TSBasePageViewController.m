//
//  TSBasePageViewController.m
//  TapShield
//
//  Created by Adam Share on 3/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBasePageViewController.h"

@interface TSBasePageViewController ()

@end

@implementation TSBasePageViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTranslucentBackground:(BOOL)translucentBackground {
    
    _translucentBackground = translucentBackground;
    
    if (translucentBackground) {
        _toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
        _toolbar.barStyle = UIBarStyleBlack;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_toolbar atIndex:0];
    }
}

@end
