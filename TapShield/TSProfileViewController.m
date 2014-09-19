//
//  TSProfileViewController.m
//  TapShield
//
//  Created by Adam Share on 2/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSProfileViewController.h"
#import "TSBasicInfoViewController.h"

static NSString * const TSProfileViewControllerBlurredProfileImage = @"TSProfileViewControllerBlurredProfileImage";

#define BLUR_AMOUNT 10

@interface TSProfileViewController ()

@property (strong, nonatomic) TSJavelinAPIUserProfile *userProfile;
@property (strong, nonatomic) NSArray *cellIdentifiers;

@end

@implementation TSProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _changeProfileButton.backgroundColor = [TSColorPalette tapshieldBlue];
    _changeProfileButton.layer.cornerRadius = 5;
    
    _tableView.backgroundColor = [TSColorPalette listBackgroundColor];
    
    _cellIdentifiers = @[@"TSBasicInfoViewController",
                         @"TSContactDataViewController",
                         @"TSAppearanceViewController",
                         @"TSMedicalInformationViewController",
                         @"TSEmergencyContactViewController"];
    
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    
    _userProfile = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].userProfile;
    if (!_userProfile) {
        _userProfile = [[TSJavelinAPIUserProfile alloc] init];
    }
    _userProfile.user = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addProfileImage:)];
    [_userImageView addGestureRecognizer:tap];
    
    UIImage *profileImage = _userImageView.image;
    UIImage *userImage = _userProfile.profileImage;
    if (userImage) {
        profileImage = userImage;
    }
    
    _userImageView.image = profileImage;
    _blurredUserImage.image = profileImage;
    
    self.translucentBackground = YES;
    self.toolbar.frame = _blurredUserImage.bounds;
    [_blurredUserImage addSubview:self.toolbar];
    
    _mediaPicker = [[UIImagePickerController alloc] init];
    [_mediaPicker setDelegate:self];
    _mediaPicker.allowsEditing = YES;
    _mediaPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self saveUserProfile];
}

- (void)saveUserProfile {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].userProfile = _userProfile;
    [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
}

#pragma mark - Camera

- (IBAction)addProfileImage:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose existing", nil];
        [actionSheet showInView:self.view];
    }
    else {
        _mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_mediaPicker animated:YES completion:nil];
    }
}


#pragma mark Camera Delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        _mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        UIAlertView * uploadRecentPhotoAlert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:@"Please take a photo of yourself from the shoulders up without sunglasses or headwear."
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"OK", nil];
        [uploadRecentPhotoAlert show];
        
    }
    else if (buttonIndex == 1) {
        _mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        UIAlertView *uploadRecentPhotoAlert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:@"Please choose a recent photo of yourself from the shoulders up without sunglasses or headwear."
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"OK", nil];
        [uploadRecentPhotoAlert show];
    }
    else {
        return;
    }
    
    [self presentViewController:_mediaPicker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image.
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    _userProfile.profileImage = image;
    
    // Save photo if user took new photo from the camera
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    _userImageView.image = image;
    _blurredUserImage.image = image;
    
    [self saveUserProfile];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TSBasicInfoViewController *viewController = (TSBasicInfoViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:_cellIdentifiers[indexPath.row]];
    
    viewController.userProfile = _userProfile;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = _cellIdentifiers[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.textColor = [TSColorPalette listCellTextColor];
    cell.textLabel.font = [UIFont fontWithName:kFontRalewayRegular size:18];
    cell.backgroundColor = [TSColorPalette cellBackgroundColor];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
    cell.separatorInset = UIEdgeInsetsMake(0.0, cell.textLabel.frame.origin.x, 0.0, 0.0);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kTalkaphoneBranding]) {
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.imageView setTintColor:[TSColorPalette tapshieldBlue]];
    }
    
    if (indexPath.row == _cellIdentifiers.count - 1) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _cellIdentifiers.count;
}



@end
