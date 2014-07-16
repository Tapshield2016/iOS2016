//
//  TSEmergencyContactTableViewController.m
//  TapShield
//
//  Created by Adam Share on 4/22/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEmergencyContactTableViewController.h"
#import "TSRelationshipViewController.h"

@interface TSEmergencyContactTableViewController ()

@end

@implementation TSEmergencyContactTableViewController


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
    
    _firstNameTextField.text = self.userProfile.emergencyContactFirstName;
    _lastNameTextField.text = self.userProfile.emergencyContactLastName;
    _phoneNumberTextField.text = self.userProfile.emergencyContactPhoneNumber;
    
    if (self.userProfile.hairColor != 0) {
        _relationshipTextField.text = [TSJavelinAPIUserProfile relationshipToLongString:self.userProfile.emergencyContactRelationship];
    }
    else {
        _relationshipTextField.placeholder = @"Choose one";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text Field Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (_phoneNumberTextField == textField) {
        textField.text = [TSUtilities formatPhoneNumber:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_phoneNumberTextField == textField) {
        NSString *alphaNumericTextField = [TSUtilities removeNonNumericalCharacters:textField.text];
        if ([string isEqualToString:@""]) {
            if ([alphaNumericTextField length] == 4) {
                textField.text = [TSUtilities removeNonNumericalCharacters:textField.text];
            }
            if ([alphaNumericTextField length] == 7) {
                textField.text = [textField.text substringToIndex:[textField.text length]-1];
            }
            return YES;
        }
        if ([alphaNumericTextField length] == 3) {
            textField.text = [NSString stringWithFormat:@"(%@) ",textField.text];
        }
        
        if ([alphaNumericTextField length] == 6) {
            textField.text = [NSString stringWithFormat:@"%@-",textField.text];
        }
        NSUInteger newTextFieldTextLength = [alphaNumericTextField length] + [string length] - range.length;
        if (newTextFieldTextLength > 10) {
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
        if (self.userProfile.emergencyContactRelationship != 0) {
            _relationshipTextField.text = [TSJavelinAPIUserProfile relationshipToLongString:self.userProfile.emergencyContactRelationship];
        }
        else {
            _relationshipTextField.text = @"";
            _relationshipTextField.placeholder = @"Choose one";
        }
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
        cell.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[self.view findFirstResponder] resignFirstResponder];
    
    if (indexPath.row == tableView.visibleCells.count - 1) {
        TSRelationshipViewController *viewController = (TSRelationshipViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSRelationshipViewController class])];
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
