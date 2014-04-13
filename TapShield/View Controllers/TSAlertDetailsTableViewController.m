//
//  TSAlertDetailsTableViewController.m
//  TapShield
//
//  Created by Adam Share on 4/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAlertDetailsTableViewController.h"


#define kCriminalArray @"Arrest", @"Arson", @"Assault", @"Burglary", @"Robbery", @"Shooting", @"Theft", @"Vandalism", nil
#define kMedicalArray @"Bleeding", @"Broken Bone", @"Choking", @"CPR", @"Heart Attack", @"High Fever", @"Stroke", nil


@interface TSAlertDetailsTableViewController ()

@property (strong, nonatomic) NSArray *policeAlertTypes;
@property (strong, nonatomic) NSArray *medicalAlertTypes;

@end

@implementation TSAlertDetailsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self whiteNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [NSArray arrayWithObjects:kMedicalArray].count;
    }
    
    return [NSArray arrayWithObjects:kCriminalArray].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Type" forIndexPath:indexPath];
    
    // Configure the cell...
    
    
    
    NSString *string;
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [[NSArray arrayWithObjects:kMedicalArray] objectAtIndex:indexPath.row];
        string = [[NSArray arrayWithObjects:kMedicalArray] objectAtIndex:indexPath.row];
        
    }
    else {
        cell.textLabel.text = [[NSArray arrayWithObjects:kCriminalArray] objectAtIndex:indexPath.row];
        string = [[NSArray arrayWithObjects:kCriminalArray] objectAtIndex:indexPath.row];
    }
    
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *imageName = [NSString stringWithFormat:@"bubble_%@_icon", [string lowercaseString]];
    cell.imageView.image = [UIImage imageNamed:imageName];
    if (!cell.imageView.image) {
        cell.imageView.image = [UIImage imageNamed:@"bubble_other_icon"];
    }
    
    cell.textLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:18.0f];
    cell.textLabel.textColor = [TSColorPalette listCellTextColor];
    cell.backgroundColor = [TSColorPalette cellBackgroundColor];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Medical";
    }
    
    return @"Police";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    
    headerView.backgroundColor = [TSColorPalette tableViewHeaderColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 10, headerView.frame.size.height)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [TSRalewayFont fontWithName:kFontRalewayMedium size:15.0f];
    [headerView addSubview:label];
    
    label.text = @"Police";
    
    if (section == 0) {
        label.text = @"Medical";
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
