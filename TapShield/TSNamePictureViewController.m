//
//  TSNamePictureViewController.m
//  TapShield
//
//  Created by Adam Share on 5/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNamePictureViewController.h"
#import "TSAgreementViewController.h"


@interface TSNamePictureViewController ()

@property (nonatomic, strong) UIImagePickerController *mediaPicker;
@property (nonatomic, strong) TSJavelinAPIUserProfile *userProfile;
@property (nonatomic, strong) UIAlertView *passcodeAlertView;

@end

@implementation TSNamePictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    
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

- (IBAction)done:(id)sender {
    
    [[self.view findFirstResponder] resignFirstResponder];
    
    if (!_firstNameTextField.text ||
        !_firstNameTextField.text.length) {
        _firstNameTextField.superview.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2];
        return;
    }
    if (!_lastNameTextField.text ||
        !_lastNameTextField.text.length) {
        _lastNameTextField.superview.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2];
        return;
    }
    
    if (!_checkBox.selected) {
        _checkBox.superview.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2];
        return;
    }
    
    _passcodeAlertView = [[UIAlertView alloc] initWithTitle:@"Enter a 4-digit passcode"
                                                    message:@"This code will be used to quickly verify your identity within the application"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    _passcodeAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [_passcodeAlertView textFieldAtIndex:0];
    [textField setPlaceholder:@"1234"];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setSecureTextEntry:YES];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [textField setDelegate:self];
    
    [_passcodeAlertView show];
}

- (IBAction)displayAgreement:(id)sender {
    
    [self pushViewControllerWithClass:[TSAgreementViewController class] transitionDelegate:nil navigationDelegate:nil animated:YES];
}

- (void)saveUserAndDismiss {
    
    if (self.presentingViewController.presentingViewController.presentingViewController) {
        [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
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


#pragma mark - Alert View Delegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == _passcodeAlertView) {
        if (buttonIndex == 1) {
            [self saveUserAndDismiss];
        }
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    textField.superview.backgroundColor = [TSColorPalette whiteColor];
    
    if (textField == _firstNameTextField ||
        textField == _lastNameTextField) {
        return YES;
    }
    
    if ([textField.text length] + [string length] - range.length == 4) {
        textField.text = [textField.text stringByAppendingString:string];
        [self checkDisarmCode:textField];
        return NO;
    }
    else if ([textField.text length] + [string length] - range.length > 4) {
        [self checkDisarmCode:textField];
        return NO;
    }
    
    return YES;
}

- (void)checkDisarmCode:(UITextField *)textField {
    
    if ([TSUtilities removeNonNumericalCharacters:textField.text].length == 4) {
        
        [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].disarmCode = textField.text;
        [_passcodeAlertView dismissWithClickedButtonIndex:1 animated:YES];
        
    }
    else {
        textField.text = @"";
        textField.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.3];
    }
}


- (IBAction)selectBox:(id)sender {
    _checkBox.superview.backgroundColor = [UIColor clearColor];
    _checkBox.selected = !_checkBox.selected;
}
@end
