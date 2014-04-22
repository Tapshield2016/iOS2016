//
//  TSAppearanceTableViewController.m
//  TapShield
//
//  Created by Adam Share on 4/22/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAppearanceTableViewController.h"

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
        _weightTextField.text = [NSString stringWithFormat:@"%i", self.userProfile.weight];
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorColor = [TSColorPalette cellSeparatorColor];
    cell.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    
    if (indexPath.row >= 2) {
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
        cell.separatorInset = UIEdgeInsetsZero;
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_heightTextField == textField) {
        NSString *alphaNumericTextField = [TSUtilities removeNonNumericalCharacters:textField.text];
        if ([string isEqualToString:@""]) {
            if ([alphaNumericTextField length] == 1) {
                textField.text = [TSUtilities removeNonNumericalCharacters:textField.text];
            }
            else if ([textField.text length] > [alphaNumericTextField length] + 2) {
                textField.text = [textField.text substringToIndex:[textField.text length]-1];
            }
            return YES;
        }
        if ([alphaNumericTextField length] == 0) {
            textField.text = [NSString stringWithFormat:@"%@'-",string];
            return NO;
        }
        
        if ([alphaNumericTextField length] == 1 && ![string isEqualToString:@"1"]) {
            textField.text = [NSString stringWithFormat:@"%@%@\"",textField.text, string];
            return NO;
        }
        else if ([alphaNumericTextField length] == 2 && [alphaNumericTextField characterAtIndex:1] - '0' == 1){
            textField.text = [NSString stringWithFormat:@"%@%@\"",textField.text, string];
            return NO;
        }
        NSUInteger newTextFieldTextLength = [alphaNumericTextField length] + [string length] - range.length;
        if (newTextFieldTextLength > 3) {
            return NO;
        }
        if (newTextFieldTextLength > 2 && [alphaNumericTextField characterAtIndex:1] - '0' != 1) {
            return NO;
        }
    }
    
    return YES;
}


@end
