//
//  TSEthnicityViewController.m
//  TapShield
//
//  Created by Adam Share on 5/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEthnicityViewController.h"

@interface TSEthnicityViewController ()

@end

@implementation TSEthnicityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.userProfile.race = indexPath.row;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return kRaceLongArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"ethnicityCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.textLabel.font = [TSRalewayFont fontWithName:kFontRalewayRegular size:18.0f];
        cell.textLabel.textColor = [TSColorPalette listCellTextColor];
        cell.backgroundColor = [TSColorPalette cellBackgroundColor];
    }
    
    cell.textLabel.text = kRaceLongArray[indexPath.row];
    if (indexPath.row) {
        if (indexPath.row == self.userProfile.race) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    return cell;
}

@end
