//
//  TSPasscodeTableViewController.m
//  TapShield
//
//  Created by Adam Share on 5/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSPasscodeTableViewController.h"

@interface TSPasscodeTableViewController ()


@end

@implementation TSPasscodeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _currentPasscodeTextField) {
        return YES;
    }
    
    textField.backgroundColor = [UIColor clearColor];
    
    NSString *alphaNumericTextField = [TSUtilities removeNonNumericalCharacters:textField.text];
    
    NSUInteger newTextFieldTextLength = [alphaNumericTextField length] + [string length] - range.length;
    
    if ([textField.text length] + [string length] - range.length == 4) {
        textField.text = [textField.text stringByAppendingString:string];
        if (textField == _passcodeTextField) {
            [_repeatPasscodeTextField becomeFirstResponder];
        }
        return NO;
    }
    
    if (newTextFieldTextLength > 4) {
        if (textField == _passcodeTextField) {
            [_repeatPasscodeTextField becomeFirstResponder];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _currentPasscodeTextField) {
        [_passcodeTextField becomeFirstResponder];
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
    
    if (indexPath.row == 2) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (IBAction)forgotPassword:(id)sender {
    
    [self.parentViewController performSelector:@selector(forgotPassword:) withObject:self];
}


@end
