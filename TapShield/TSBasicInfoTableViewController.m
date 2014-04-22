//
//  TSBasicInfoTableViewController.m
//  TapShield
//
//  Created by Adam Share on 4/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBasicInfoTableViewController.h"

@interface TSBasicInfoTableViewController ()

@end

@implementation TSBasicInfoTableViewController

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
    
    _firstNameTextField.text = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].firstName;
    _lastNameTextField.text = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].lastName;
    _birthdayTextField.text = self.userProfile.birthday;
    
    if (self.userProfile.gender != 0) {
        _genderTextField.text = [TSJavelinAPIUserProfile genderToLongString:self.userProfile.gender];
    }
    else {
        _genderTextField.placeholder = [TSJavelinAPIUserProfile genderToLongString:self.userProfile.gender];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    if (indexPath.row == 3) {
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorColor = [TSColorPalette cellSeparatorColor];
    cell.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    
    if (indexPath.row == 3) {
        
        if (self.userProfile.gender != 0) {
            NSString *imageName = [NSString stringWithFormat:@"settings_%@_icon", [TSJavelinAPIUserProfile genderToLongString:self.userProfile.gender]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
            imageView.contentMode = UIViewContentModeLeft;
            CGRect frame = imageView.frame;
            frame.size.width += frame.size.width/2;
            imageView.frame = frame;
            
            _genderTextField.leftView = imageView;
            _genderTextField.leftViewMode = UITextFieldViewModeAlways;
        }
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
        cell.separatorInset = UIEdgeInsetsZero;
    }
}

@end
