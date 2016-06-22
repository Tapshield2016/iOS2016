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
        _genderTextField.placeholder = @"Choose one";
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
        
        NSString *newAlphaNumericText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        newAlphaNumericText = [TSUtilities removeNonNumericalCharacters:newAlphaNumericText];
        
        if (newAlphaNumericText.length > 8) {
            return NO;
        }
        NSString *subString;
        
        switch (newAlphaNumericText.length) {
            case 1:
                if (newAlphaNumericText.intValue > 1) {
                    textField.text = [NSString stringWithFormat:@"0%@-", newAlphaNumericText];
                }
                else {
                    return YES;
                }
                break;
            case 2:
                if (newAlphaNumericText.intValue > 12) {
                    return NO;
                }
                textField.text = [NSString stringWithFormat:@"%@-", newAlphaNumericText];
                break;
            case 3:
                if (string.intValue > 3) {
                    textField.text = [NSString stringWithFormat:@"%@-0%@", [newAlphaNumericText substringToIndex:2], [newAlphaNumericText substringFromIndex:2]];
                }
                else {
                    textField.text = [NSString stringWithFormat:@"%@-%@", [newAlphaNumericText substringToIndex:2], [newAlphaNumericText substringFromIndex:2]];
                }
                break;
            case 4:
                if ([newAlphaNumericText substringFromIndex:2].intValue > [NSDate daysInMonth:[newAlphaNumericText substringToIndex:2].integerValue]) {
                    return NO;
                }
                textField.text = [NSString stringWithFormat:@"%@-%@-", [newAlphaNumericText substringToIndex:2], [newAlphaNumericText substringFromIndex:2]];
                break;
            
            case 5:
                subString = [newAlphaNumericText substringFromIndex:4];
                if (subString.intValue > 2) {
                    textField.text = [NSString stringWithFormat:@"%@-%@-19%@", [newAlphaNumericText substringToIndex:2], [newAlphaNumericText substringWithRange:NSMakeRange(2, 2)], subString];
                }
                else {
                    if (subString.intValue == 2) {
                        textField.text = [NSString stringWithFormat:@"%@-%@-20", [newAlphaNumericText substringToIndex:2], [newAlphaNumericText substringWithRange:NSMakeRange(2, 2)]];
                    }
                    else if (subString.intValue == 1) {
                        textField.text = [NSString stringWithFormat:@"%@-%@-19", [newAlphaNumericText substringToIndex:2], [newAlphaNumericText substringWithRange:NSMakeRange(2, 2)]];
                    }
                    else if (subString.intValue == 0) {
                        textField.text = [NSString stringWithFormat:@"%@-%@-200", [newAlphaNumericText substringToIndex:2], [newAlphaNumericText substringWithRange:NSMakeRange(2, 2)]];
                    }
                }
                break;
                
            default:
                
                if ([newAlphaNumericText substringFromIndex:4].intValue > [NSDate date].year) {
                    return NO;
                }
                if (newAlphaNumericText.length > 4) {
                    textField.text = [NSString stringWithFormat:@"%@-%@-%@", [newAlphaNumericText substringToIndex:2], [newAlphaNumericText substringWithRange:NSMakeRange(2, 2)], [newAlphaNumericText substringFromIndex:4]];
                }
                break;
        }
        
        return NO;
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
            NSString *imageName = [NSString stringWithFormat:@"settings_%@_icon", [[TSJavelinAPIUserProfile genderToLongString:self.userProfile.gender] lowercaseString]];
            
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
            _genderTextField.placeholder = @"Choose one";
        }
        
        
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
        cell.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[self.view findFirstResponder] resignFirstResponder];
    
    if (indexPath.row == tableView.visibleCells.count - 1) {
        TSGenderViewController *viewController = (TSGenderViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSGenderViewController class])];
        viewController.userProfile = self.userProfile;
        [self.parentViewController.navigationController pushViewController:viewController animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < 3) {
        return NO;
    }
    
    return YES;
}

@end
