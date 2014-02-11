//
//  TSJavelinS3UploadManager.m
//  Javelin
//
//  Created by Ben Boyd on 12/4/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinS3UploadManager.h"
#import "UIImage+Resize.h"

static NSString * const kTSJavelinS3UploadManagerDevelopmentAccessKey = @"AKIAJHIUM7YWZW2T2YIA";
static NSString * const kTSJavelinS3UploadManagerDevelopmentSecretKey = @"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";

#ifdef APP_STORE
static NSString * const kTSJavelinS3UploadManagerDevelopmentBucketName = @"media.tapshield.com";
#else
static NSString * const kTSJavelinS3UploadManagerDevelopmentBucketName = @"dev.media.tapshield.com";
#endif

@implementation TSJavelinS3UploadManager

- (void)uploadUIImageToS3:(UIImage *)image imageName:(NSString *)imageName completion:(void (^)(NSString *imageS3URL))completion {
    UIImage *croppedImage = [image resizeAndCropToSize:CGSizeMake(150, 150)];
    NSData *imageData = UIImageJPEGRepresentation(croppedImage, 0.5f);
    [self processUpload:imageData key:imageName completion:completion];
}

- (void)processUpload:(NSData *)fileData key:(NSString *)key completion:(void (^)(NSString *imageS3URL))completion {
    [AmazonLogger verboseLogging];
    _s3 = [[AmazonS3Client alloc] initWithAccessKey:kTSJavelinS3UploadManagerDevelopmentAccessKey
                                      withSecretKey:kTSJavelinS3UploadManagerDevelopmentSecretKey];
    _s3.timeout = 240;

    dispatch_async(dispatch_get_main_queue(), ^{

        S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:key
                                                                              inBucket:kTSJavelinS3UploadManagerDevelopmentBucketName];
        // Make the object publicly readable
        putObjectRequest.cannedACL = [S3CannedACL publicRead];
        putObjectRequest.contentType = @"image/jpeg";
        putObjectRequest.data = fileData;
        //putObjectRequest.delegate = self;

        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:putObjectRequest];
        if (putObjectResponse.error != nil) {
            NSLog(@"Error: %@", putObjectResponse.error);
            if (completion) {
                completion(nil);
            }
        }
        else {
            NSLog(@"The image was successfully uploaded.");
            if (completion) {
                completion([NSString stringWithFormat:@"http://%@.s3.amazonaws.com/%@", kTSJavelinS3UploadManagerDevelopmentBucketName, key]);
            }
        }
    });
}


#pragma mark - AmazonServiceRequestDelegate methods

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
    NSLog(@"%@", response);
}

@end
