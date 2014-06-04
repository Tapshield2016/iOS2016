//
//  TSSoundFileFolderViewController.m
//  TapShield
//
//  Created by Adam Share on 6/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSoundFileFolderViewController.h"

@interface TSSoundFileFolderViewController ()

@end

@implementation TSSoundFileFolderViewController

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
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = item;
    
    [self.navigationController setNavigationBarHidden:NO];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _descriptionView.media = [self soundFileURLForFilePathName:[[self filePathArray] objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        [self deleteFile:[[self filePathArray] objectAtIndex:indexPath.row] indexPath:indexPath];
    }
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
    
    return [self filePathArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellID = @"AudioFilesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    
    NSString *path = [[self filePathArray] objectAtIndex:indexPath.row];
    cell.textLabel.text = [[path stringByDeletingPathExtension] stringByRemovingPercentEncoding];
    
    
    return cell;
}

#pragma mark - File Paths

- (NSArray *)filePathArray {
    
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *newFolderPath = [documentsDirectory stringByAppendingPathComponent:@"/recorded"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:newFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"/recorded"]  error:nil];
    
    return filePathsArray;
}

- (NSURL *)soundFileURLForFilePathName:(NSString *)name {
    
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *newFolderPath = [documentsDirectory stringByAppendingPathComponent:@"/recorded"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:newFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSString *fileName = [NSString stringWithFormat:@"/recorded/%@", name];
    NSString *soundFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    return [NSURL fileURLWithPath:soundFilePath];
}

- (void)deleteFile:(NSString *)name indexPath:(NSIndexPath *)indexPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    if ([fileManager fileExistsAtPath:[[self soundFileURLForFilePathName:name] path]]) {
        [fileManager removeItemAtPath:[[self soundFileURLForFilePathName:name] path]  error:&error];
    }
    
    if (!error) {
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

@end
