//
//  TSReportDescriptionViewController.m
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSReportDescriptionViewController.h"
#import "TSSpotCrimeAPIClient.h"
#import "TSSpotCrimeAnnotation.h"
#import "TSJavelinS3UploadManager.h"
#import "TSJavelinAPIUtilities.h"
#import <AVFoundation/AVFoundation.h>

static NSString * const kDefaultMediaImage = @"image_deafult";

@interface TSReportDescriptionViewController ()

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIActionSheet *recordActionSheet;
@property (strong, nonatomic) UIActionSheet *fileActionSheet;
@property (strong, nonatomic) TSBaseLabel *uploadingLabel;
@property (strong, nonatomic) id media;

@end

@implementation TSReportDescriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.navigationItem.title = @"Description";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [TSColorPalette listBackgroundColor];
    _imageView.image = _image;
    _typeLabel.text = _type;
    _timeLabel.text = [TSUtilities formattedViewableDate:[NSDate date]];
    _addressLabel.text = @"";
    _location = [TSLocationController sharedLocationController].location;
    
    _detailsTextView.layer.cornerRadius = 5;
    _detailsTextView.placeholder = @"Enter your non-emergency tip details here (call 911 if this is an emergency)";
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks) {
                CLPlacemark *placemark = [placemarks firstObject];
                NSString *title = @"";
                NSString *subtitle = @"";
                if (placemark.subThoroughfare) {
                    title = placemark.subThoroughfare;
                }
                if (placemark.thoroughfare) {
                    title = [NSString stringWithFormat:@"%@ %@", title, placemark.thoroughfare];
                }
                if (placemark.locality) {
                    subtitle = placemark.locality;
                }
                if (placemark.administrativeArea) {
                    if (placemark.locality) {
                        subtitle = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                    }
                    else {
                        subtitle = placemark.administrativeArea;
                    }
                }
                if (placemark.postalCode) {
                    subtitle = [NSString stringWithFormat:@"%@ %@", subtitle, placemark.postalCode];
                }
                
                if (!title) {
                    title = subtitle;
                }
                
                _addressLabel.text = title;
            }
        }];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Report" style:UIBarButtonItemStyleBordered target:self action:@selector(reportEvent)];
    self.navigationItem.rightBarButtonItem = item;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _uploadingLabel = [[TSBaseLabel alloc] initWithFrame:_shimmeringView.frame];
    _uploadingLabel.textAlignment = NSTextAlignmentCenter;
    _uploadingLabel.textColor = [TSColorPalette whiteColor];
    _uploadingLabel.shadowColor = [UIColor blackColor];
    _uploadingLabel.text = @"Uploading";
    _uploadingLabel.hidden = YES;
    _shimmeringView.contentView = _uploadingLabel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMedia:(id)media {
    
    _media = media;
    
    if (media) {
        _mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_addMediaButton setTitle:@"Change media" forState:UIControlStateNormal];
    }
    else {
        _mediaImageView.contentMode = UIViewContentModeCenter;
        _mediaImageView.image = [UIImage imageNamed:kDefaultMediaImage];
        [_addMediaButton setTitle:@"Add media" forState:UIControlStateNormal];
    }
}

- (void)reportEvent {
    
    [[self.navigationItem rightBarButtonItem] setEnabled:NO];
    
    _shimmeringView.shimmering = YES;
    _uploadingLabel.hidden = NO;
    
    [self dismissKeyboard];
    
    if (!_detailsTextView.text || !_detailsTextView.text.length) {
        _detailsTextView.text = _type;
    }
    
    [self uploadMedia:^(NSString *urlString) {
        
        NSArray *array = [NSArray arrayWithObjects:kSocialCrimeReportLongArray];
        int index = [array indexOfObject:_type];
        
        TSJavelinAPISocialCrimeReport *report = [[TSJavelinAPISocialCrimeReport alloc] init];
        report.body = _detailsTextView.text;
        report.reportType = index;
        report.location = _location;
        
        if (urlString) {
            if ([_media isKindOfClass:[UIImage class]]) {
                report.reportImageUrl = urlString;
            }
            else if ([_media isKindOfClass:[NSURL class]]) {
                report.reportVideoUrl = urlString;
            }
        }
        
        [[TSJavelinAPIClient sharedClient] postSocialCrimeReport:report completion:^(TSJavelinAPISocialCrimeReport *report) {
            
            if (report) {
                report.address = _addressLabel.text;
                
                UINavigationController *parentNavigationController;
                if ([[self.presentingViewController.childViewControllers firstObject] isKindOfClass:[UINavigationController class]]) {
                    parentNavigationController = (UINavigationController *)[self.presentingViewController.childViewControllers firstObject];
                }
                else if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
                    parentNavigationController = (UINavigationController *)self.presentingViewController;
                }
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [_reportManager addUserSocialReport:report];
                    [parentNavigationController.topViewController viewWillAppear:NO];
                    [parentNavigationController.topViewController viewDidAppear:NO];
                }];
            }
            else {
                [[self.navigationItem rightBarButtonItem] setEnabled:YES];
            }
        }];
    }];
    
    
}

- (void)uploadMedia:(void(^)(NSString *urlString))completion {
    
    if (!_media) {
        if (completion) {
            completion(nil);
        }
    }
    
    TSJavelinS3UploadManager *uploadManager = [[TSJavelinS3UploadManager alloc] init];
    
    NSString *key;
    
    if ([_media isKindOfClass:[NSURL class]]) {
        key = [NSString stringWithFormat:@"social-crime/video/%@.mov", [TSJavelinAPIUtilities uuidString]];
        NSData *videoData = [NSData dataWithContentsOfURL:_media];
        [uploadManager uploadVideoData:videoData
                                   key:key
                            completion:completion];
    }
    else if ([_media isKindOfClass:[UIImage class]]) {
        key = [NSString stringWithFormat:@"social-crime/image/%@.jpg", [TSJavelinAPIUtilities uuidString]];
        [uploadManager uploadUncompressedUIImageToS3:_media
                                           imageName:key
                                          completion:completion];
    }
    else {
        if (completion) {
            completion(nil);
        }
    }
    
    
}

#pragma mark - Add Media

- (IBAction)chooseMedia:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showRecordActionSheet];
    }
    else {
        [self showFileActionSheet];
    }
}

- (void)showRecordActionSheet {
    
    NSString *destructiveButtonTitle;
    if (_media) {
        destructiveButtonTitle = @"Remove media";
    }
    
    _recordActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:destructiveButtonTitle
                                            otherButtonTitles:@"Camera", @"Record audio", @"Saved media", nil];
    _recordActionSheet.tintColor = [TSColorPalette tapshieldBlue];
    [_recordActionSheet showInView:self.view];
}

- (void)showFileActionSheet {
    
    NSString *destructiveButtonTitle;
    if (_media) {
        destructiveButtonTitle = @"Remove media";
    }
    
    _fileActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:destructiveButtonTitle
                                          otherButtonTitles:@"Photo", @"Video", @"Audio", nil];
    _fileActionSheet.tintColor = [TSColorPalette tapshieldBlue];
    [_fileActionSheet showInView:self.view];
}

#pragma mark Action Sheet Delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (!_imagePicker) {
        
        _imagePicker = [[UIImagePickerController alloc] init];
        [_imagePicker setDelegate:self];
        _imagePicker.allowsEditing = YES;
    }
    
    int i = 0;
    
    if (actionSheet.destructiveButtonIndex == 0) {
        i = 1;
    }
    
    if (actionSheet == _recordActionSheet) {
        
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        
        
        if (buttonIndex == 0 + i) {
            
            _imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:_imagePicker animated:YES completion:nil];
        }
        else if (buttonIndex == 1 + i) {
            
        }
        else if (buttonIndex == 2 + i) {
            [self showFileActionSheet];
        }
        else if (buttonIndex == actionSheet.destructiveButtonIndex) {
            self.media = nil;
        }
    }
    else if (actionSheet == _fileActionSheet) {
    
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        if (buttonIndex == 0 + i) {
            
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
            [self presentViewController:_imagePicker animated:YES completion:nil];
        }
        else if (buttonIndex == 1 + i) {
            
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
            [self presentViewController:_imagePicker animated:YES completion:nil];
        }
        else if (buttonIndex == 2 + i) {
            
        }
        else if (buttonIndex == actionSheet.destructiveButtonIndex) {
            self.media = nil;
        }
    }
}

#pragma mark Image Picker Delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image;
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
        NSURL *videoUrl = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        image = [self videoThumbnail:videoUrl];
        self.media = videoUrl;
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            NSString *moviePath = [videoUrl path];
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
            }
        }
    }
    else {
        // Get the selected image.
        image = [info objectForKey:UIImagePickerControllerEditedImage];
        self.media = image;
        
        // Save photo if user took new photo from the camera
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }
    
    _mediaImageView.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*)videoThumbnail:(NSURL *)videoUrl {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    CMTime duration = asset.duration;
    int seconds = (int)duration.value/duration.timescale;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    NSError *err = NULL;
    CMTime time = CMTimeMake(seconds/2, 1);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    
    if (err) {
        NSLog(@"err==%@, imageRef==%@", err, imgRef);
    }
    
    UIImage *thumnail = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return thumnail;
}


#pragma mark Media Picker Delegate methods

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Keyboard Notifications

- (void)dismissKeyboard {
    
    [_detailsTextView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardBounds.size.height;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0f, keyboardBounds.size.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    CGRect rect = [self.view findFirstResponder].frame;
    
    CGPoint basePoint = rect.origin;
    basePoint.y += rect.size.height;
    
    if (!CGRectContainsPoint(aRect, basePoint) ) {
        CGPoint scrollPoint = CGPointMake(0.0, basePoint.y - keyboardBounds.size.height);
        [_scrollView setContentOffset:scrollPoint];
    }
    
    [UIView commitAnimations];
    
    [_scrollView setScrollEnabled:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

@end
