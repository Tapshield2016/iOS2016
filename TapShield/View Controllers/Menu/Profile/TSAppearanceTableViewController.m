//
//  TSAppearanceTableViewController.m
//  TapShield
//
//  Created by Adam Share on 4/22/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAppearanceTableViewController.h"
#import "TSHairColorViewController.h"
#import "TSEthnicityViewController.h"

@interface TSAppearanceTableViewController ()

@end

@implementation TSAppearanceTableViewController

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
    _heightTextField.text = self.userProfile.height;
    if (self.userProfile.weight) {
        _weightTextField.text = [NSString stringWithFormat:@"%lu lbs", (unsigned long)self.userProfile.weight];
    }
    
    if (self.userProfile.hairColor != 0) {
        _hairColorTextField.text = [TSJavelinAPIUserProfile hairColorToLongString:self.userProfile.hairColor];
    }
    else {
        _hairColorTextField.placeholder = @"Choose one";
    }
    
    if (self.userProfile.race != 0) {
        _ethnicityTextField.text = [TSJavelinAPIUserProfile raceToLongString:self.userProfile.race];
    }
    else {
        _ethnicityTextField.placeholder = @"Choose one";
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
    
    if (indexPath.row < 2) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorColor = [TSColorPalette cellSeparatorColor];
    cell.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    
    if (indexPath.row >= 2) {
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
    }
    
    if (indexPath.row == 2) {
        
        if (self.userProfile.hairColor != 0) {
            _hairColorTextField.text = [TSJavelinAPIUserProfile hairColorToLongString:self.userProfile.hairColor];
        }
        else {
            _hairColorTextField.text = @"";
            _hairColorTextField.placeholder = @"Choose one";
        }
    }
    
    if (indexPath.row == 3) {
        
        if (self.userProfile.race != 0) {
            _ethnicityTextField.text = [TSJavelinAPIUserProfile raceToLongString:self.userProfile.race];
        }
        else {
            _ethnicityTextField.text = @"";
            _ethnicityTextField.placeholder = @"Choose one";
        }
        
        cell.separatorInset = UIEdgeInsetsZero;
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_heightTextField == textField) {
        NSString *alphaNumericText = [TSUtilities removeNonNumericalCharacters:textField.text];
        if ([string isEqualToString:@""]) {
            if ([alphaNumericText length] == 1) {
                textField.text = [TSUtilities removeNonNumericalCharacters:textField.text];
            }
            else if ([textField.text length] > [alphaNumericText length] + 2) {
                textField.text = [textField.text substringToIndex:[textField.text length]-1];
            }
            return YES;
        }
        
        if ([alphaNumericText length] == 0) {
            textField.text = [NSString stringWithFormat:@"%@'-",string];
            return NO;
        }
        
        if ([alphaNumericText length] == 1 && ![string isEqualToString:@"1"]) {
            textField.text = [NSString stringWithFormat:@"%@%@\"",textField.text, string];
            return NO;
        }
        else if ([alphaNumericText length] == 2 && [alphaNumericText characterAtIndex:1] - '0' == 1){
            textField.text = [NSString stringWithFormat:@"%@%@\"",textField.text, string];
            return NO;
        }
        NSUInteger newTextFieldTextLength = [alphaNumericText length] + [string length] - range.length;
        if (newTextFieldTextLength > 3) {
            return NO;
        }
        if (newTextFieldTextLength > 2 && [alphaNumericText characterAtIndex:1] - '0' != 1) {
            return NO;
        }
    }
    
    if (_weightTextField == textField) {
        
        NSString *alphaNumericText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        alphaNumericText = [TSUtilities removeNonNumericalCharacters:alphaNumericText];
        alphaNumericText = [alphaNumericText stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (alphaNumericText.length) {
            textField.text = textField.text = [NSString stringWithFormat:@"%@ lbs", alphaNumericText];
            [textField setSelectedRange:NSMakeRange(alphaNumericText.length, 0)];
        }
        else {
            textField.text = @"";
        }
        
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (_weightTextField == textField) {
        NSString *alphaNumericText = [TSUtilities removeNonNumericalCharacters:textField.text];
        alphaNumericText = [alphaNumericText stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (alphaNumericText.length) {
            [textField setSelectedRange:NSMakeRange(alphaNumericText.length, 0)];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[self.view findFirstResponder] resignFirstResponder];
    
    if (indexPath.row == tableView.visibleCells.count - 2) {
        TSHairColorViewController *viewController = (TSHairColorViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSHairColorViewController class])];
        viewController.userProfile = self.userProfile;
        [self.parentViewController.navigationController pushViewController:viewController animated:YES];
    }
    
    if (indexPath.row == tableView.visibleCells.count - 1) {
        TSEthnicityViewController *viewController = (TSEthnicityViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSEthnicityViewController class])];
        viewController.userProfile = self.userProfile;
        [self.parentViewController.navigationController pushViewController:viewController animated:YES];
    }
}


@end
