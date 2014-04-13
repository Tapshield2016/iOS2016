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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dismissViewController:(id)sender {
}
@end
