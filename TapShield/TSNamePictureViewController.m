//
//  TSNamePictureViewController.m
//  TapShield
//
//  Created by Adam Share on 5/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNamePictureViewController.h"


@interface TSNamePictureViewController ()

@property (nonatomic, strong) UIImagePickerController *mediaPicker;
@property (nonatomic, strong)  TSJavelinAPIUserProfile *userProfile;

@end

@implementation TSNamePictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addProfileImage:)];
    [_imageView addGestureRecognizer:tap];
    
    _userProfile = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].userProfile;
    if (!_userProfile) {
        _userProfile = [[TSJavelinAPIUserProfile alloc] init];
    }
    
    _mediaPicker = [[UIImagePickerController alloc] init];
    [_mediaPicker setDelegate:self];
    _mediaPicker.allowsEditing = YES;
    _mediaPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (IBAction)dismissRegistration:(id)sender {
    
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].firstName = _firstNameTextField.text;
    [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].lastName = _lastNameTextField.text;
    [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
    [[[TSJavelinAPIClient sharedClient] authenticationManager] updateLoggedInUser:nil];
}

- (void)saveUserProfile {
    
    [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].userProfile = _userProfile;
    [[[TSJavelinAPIClient sharedClient] authenticationManager] archiveLoggedInUser];
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
    
    _imageView.image = image;
    
    [self saveUserProfile];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
