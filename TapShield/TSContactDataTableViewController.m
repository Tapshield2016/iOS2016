//
//  TSContactDataTableViewController.m
//  TapShield
//
//  Created by Adam Share on 4/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSContactDataTableViewController.h"

@interface TSContactDataTableViewController ()

@end

@implementation TSContactDataTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _streetTextField.text = [self.userProfile.addressDictionary objectForKey:@"Street"];
    _cityTextField.text = [self.userProfile.addressDictionary objectForKey:@"City"];
    _stateTextField.text = [self.userProfile.addressDictionary objectForKey:@"State"];
    _zipTextField.text = [self.userProfile.addressDictionary objectForKey:@"Zip code"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)fullAddressDictionary {
    
    NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    if (_streetTextField.text && _streetTextField.text.length > 0) {
        [addressDictionary setObject:_streetTextField.text forKey:@"Street"];
    }
    if (_cityTextField.text && _cityTextField.text.length > 0) {
        [addressDictionary setObject:_cityTextField.text forKey:@"City"];
    }
    if (_stateTextField.text && _stateTextField.text.length > 0) {
        [addressDictionary setObject:_stateTextField.text forKey:@"State"];
    }
    if (_zipTextField.text && _zipTextField.text.length > 0) {
        [addressDictionary setObject:_zipTextField.text forKey:@"Zip code"];
    }
    
    return addressDictionary;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorColor = [TSColorPalette cellSeparatorColor];
    cell.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    
    if (indexPath.row == 3) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
}

@end
