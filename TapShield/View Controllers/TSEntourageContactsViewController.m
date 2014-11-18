//
//  TSEntourageContactsViewController.m
//  TapShield
//
//  Created by Adam Share on 10/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageContactsViewController.h"
#import "TSJavelinAPIEntourageMember.h"
#import "TSEntourageContactTableViewCell.h"

@interface TSEntourageContactsViewController ()

@end

@implementation TSEntourageContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    _tableViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSEntourageContactsTableViewController class])];
    _tableViewController.view.frame = CGRectMake(53, 0, self.view.frame.size.width-53, self.view.frame.size.height);
    [self.view addSubview:_tableViewController.view];
    [self addChildViewController:_tableViewController];
    [_tableViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
}



@end
