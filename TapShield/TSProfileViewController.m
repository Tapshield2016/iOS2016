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
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
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
    
    _changeProfileButton.backgroundColor = [TSColorPalette tapshieldBlue];
    _changeProfileButton.layer.cornerRadius = 5;
    
    UIImage *profileImage = _userImageView.image;
    UIImage *userImage = _userProfile.profileImage;
    if (userImage) {
        profileImage = userImage;
    }
    else {
        [_changeProfileButton setTitle:@"Add Photo" forState:UIControlStateNormal];
    }
    
    _userImageView.image = profileImage;
    _blurredUserImage.image = profileImage;
    
    _userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _userImageView.layer.borderWidth = 3.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self drawerCanDragForMenu:YES];
    
    if ([TSJavelinAPIClient loggedInUser].firstAndLastName) {
        _nameLabel.text = [TSJavelinAPIClient loggedInUser].firstAndLastName;
        _nameLabel.adjustsFontSizeToFitWidth = YES;
    }
    else {
        _nameLabel.text = @"";
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    _mediaPicker = [[UIImagePickerController alloc] init];
    [_mediaPicker setDelegate:self];
    _mediaPicker.allowsEditing = YES;
    _mediaPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
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
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Profile picture" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            _mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            UIAlertController *message = [UIAlertController alertControllerWithTitle:@"Please take a photo of yourself from the shoulders up without sunglasses or headwear." message:nil preferredStyle:UIAlertControllerStyleAlert];
            [message addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:_mediaPicker animated:YES completion:^{
                [_mediaPicker presentViewController:message animated:YES completion:nil];
            }];
        }];
        UIAlertAction *chooseExisting = [UIAlertAction actionWithTitle:@"Choose existing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            _mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            UIAlertController *message = [UIAlertController alertControllerWithTitle:@"Please choose a recent photo of yourself from the shoulders up without sunglasses or headwear." message:nil preferredStyle:UIAlertControllerStyleAlert];
            [message addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:_mediaPicker animated:YES completion:^{
                [_mediaPicker presentViewController:message animated:YES completion:nil];
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:takePhoto];
        [alertController addAction:chooseExisting];
        [alertController addAction:cancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        _mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_mediaPicker animated:YES completion:nil];
    }
}


#pragma mark Camera Delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image.
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    _userProfile.profileImage = image;
    
    [_changeProfileButton setTitle:@"Change Photo" forState:UIControlStateNormal];
    
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
    
    [self drawerCanDragForMenu:NO];
    
    TSBasicInfoViewController *viewController = (TSBasicInfoViewController *)[[UIStoryboard storyboardWithName:kTSConstanstsMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:_cellIdentifiers[indexPath.row]];
    
    viewController.userProfile = _userProfile;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = _cellIdentifiers[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.textColor = [TSColorPalette listCellTextColor];
    cell.textLabel.font = [UIFont fontWithName:kFontWeightLight size:18];
    cell.backgroundColor = [TSColorPalette cellBackgroundColor];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_icon"]];
    cell.separatorInset = UIEdgeInsetsMake(0.0, (cell.textLabel.frame.origin.x + cell.textLabel.layoutMargins.left)*2, 0.0, 0.0);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kTalkaphoneBranding]) {
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.imageView setTintColor:[TSColorPalette tapshieldBlue]];
    }
    
    if (indexPath.row == _cellIdentifiers.count - 1) {
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
        bottomBorder.frame = CGRectMake(0, cell.frame.size.height-.5, cell.frame.size.width, 0.5);
        [cell.layer addSublayer:bottomBorder];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _cellIdentifiers.count;
}



@end
