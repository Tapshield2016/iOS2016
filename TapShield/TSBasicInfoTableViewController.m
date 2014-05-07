//
//  TSBasicInfoTableViewController.m
//  TapShield
//
//  Created by Adam Share on 4/21/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBasicInfoTableViewController.h"
#import "TSGenderViewController.h"

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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_birthdayTextField == textField) {
        NSString *alphaNumericTextField = [TSUtilities removeNonNumericalCharacters:textField.text];
        if ([string isEqualToString:@""]) {
            if ([alphaNumericTextField length] == 3) {
                textField.text = [TSUtilities removeNonNumericalCharacters:textField.text];
            }
            if ([alphaNumericTextField length] == 5) {
                textField.text = [textField.text substringToIndex:[textField.text length]-1];
            }
            return YES;
        }
        if ([alphaNumericTextField length] == 2) {
            textField.text = [NSString stringWithFormat:@"%@-",textField.text];
        }
        
        if ([alphaNumericTextField length] == 4) {
            textField.text = [NSString stringWithFormat:@"%@-",textField.text];
        }
        NSUInteger newTextFieldTextLength = [alphaNumericTextField length] + [string length] - range.length;
        if (newTextFieldTextLength > 8) {
            return NO;
        }
    }
    
    return YES;
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
            _genderTextField.text = [TSJavelinAPIUserProfile genderToLongString:self.userProfile.gender];
        }
        else {
            _genderTextField.leftView = nil;
            _genderTextField.text = @"";
            _genderTextField.placeholder = [TSJavelinAPIUserProfile genderToLongString:self.userProfile.gender];
        }
        
        
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
        cell.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == tableView.visibleCells.count - 1) {
        TSGenderViewController *viewController = (TSGenderViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSGenderViewController class])];
        viewController.userProfile = self.userProfile;
        [self.parentViewController.navigationController pushViewController:viewController animated:YES];
    }
}

@end
