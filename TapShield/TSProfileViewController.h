//
//  TSProfileViewController.h
//  TapShield
//
//  Created by Adam Share on 2/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSRoundImageView.h"

@interface TSProfileViewController : TSNavigationViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet TSRoundImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredUserImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIImagePickerController *mediaPicker;

@end
