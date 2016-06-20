//
//  TSJavelinS3UploadManager.m
//  Javelin
//
//  Created by Ben Boyd on 12/4/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinS3UploadManager.h"
#import "UIImage+Resize.h"
#import "TSUtilities.h"
#import "TSJavelinAPIUtilities.h"
static NSString * const kTSJavelinS3ConfigKey = @"AWSS3East";
static NSString * const kTSJavelinS3UploadManagerAccessKey = @"AKIAJHIUM7YWZW2T2YIA";
static NSString * const kTSJavelinS3UploadManagerSecretKey = @"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";

#ifdef APP_STORE
static NSString * const kTSJavelinS3UploadManagerBucketName = @"media.tapshield.com";
#else
static NSString * const kTSJavelinS3UploadManagerBucketName = @"dev.media.tapshield.com";
#endif

@implementation TSJavelinS3UploadManager

- (void)uploadUIImageToS3:(UIImage *)image imageName:(NSString *)imageName completion:(void (^)(NSString *imageS3URL))completion {
    UIImage *croppedImage = [image resizeAndCropToSize:CGSizeMake(150, 150)];
    NSData *imageData = UIImageJPEGRepresentation(croppedImage, 0.5f);
    [self uploadData:imageData key:imageName type:@"image/jpeg" completion:completion];
}

- (void)uploadUncompressedUIImageToS3:(UIImage *)image imageName:(NSString *)imageName completion:(void (^)(NSString *imageS3URL))completion {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    [self uploadData:imageData key:imageName type:@"image/jpeg" completion:completion];
}

- (void)uploadData:(NSData *)fileData key:(NSString *)key type:(NSString *)type completion:(void (^)(NSString *imageS3URL))completion {
    
    AWSServiceConfiguration *configuration;
    AWSStaticCredentialsProvider *credentialsProvider;
    
    credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:kTSJavelinS3UploadManagerAccessKey secretKey:kTSJavelinS3UploadManagerSecretKey];
    configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSS3 *transferManager = [AWSS3 S3ForKey:kTSJavelinS3ConfigKey];
    if (!transferManager) {
        [AWSS3 registerS3WithConfiguration:configuration forKey:kTSJavelinS3ConfigKey];
        transferManager = [AWSS3 S3ForKey:kTSJavelinS3ConfigKey];
    }
    
    AWSS3PutObjectRequest *request = [AWSS3PutObjectRequest new];
    request.bucket = kTSJavelinS3UploadManagerBucketName;
    request.key = key;
    request.body = fileData;
    request.contentLength = @(fileData.length);
    request.contentType = type;
    request.ACL = AWSS3ObjectCannedACLPublicRead;
    
    AWSTask *transfer = [transferManager putObject:request];
    [transfer continueWithBlock:^id(AWSTask *task) {
        
        if(task.error) {
            NSLog(@"Error: %@",task.error);
            if (completion) {
                completion(nil);
            }
        }
        else {
            NSLog(@"Got here: %@", task.result);
            if (completion) {
                completion([NSString stringWithFormat:@"http://%@.s3.amazonaws.com/%@", kTSJavelinS3UploadManagerBucketName, key]);
            }
        }
        return nil;
    }];
    
//    _s3 = [[AmazonS3Client alloc] initWithAccessKey:kTSJavelinS3UploadManagerDevelopmentAccessKey
//                                      withSecretKey:kTSJavelinS3UploadManagerDevelopmentSecretKey];
//    _s3.timeout = 240;
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:key
//                                                                              inBucket:kTSJavelinS3UploadManagerDevelopmentBucketName];
//        // Make the object publicly readable
//        putObjectRequest.cannedACL = [S3CannedACL publicRead];
//        putObjectRequest.contentType = @"image/jpeg";
//        putObjectRequest.data = fileData;
//        //putObjectRequest.delegate = self;
//
//        // Put the image data into the specified s3 bucket and object.
//        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:putObjectRequest];

//    });
}

- (void)convertToMP4andUpload:(NSURL *)videoUrl completion:(void (^)(NSString *videoS3URL))completion {
    
    NSString *randomKey = [NSString stringWithFormat:@"social-crime/video/%@.mp4", [TSJavelinAPIUtilities uuidString]];
    
    [TSUtilities convertToMP4:[videoUrl path] completion:^(AVAssetExportSessionStatus status, NSString *path) {
        
        if (status == AVAssetExportSessionStatusFailed) {
            if (completion) {
                completion(nil);
            }
        }
        
        if (status == AVAssetExportSessionStatusCompleted) {
            NSData *videoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
            [self uploadData:videoData
                         key:randomKey
                        type:@"video/mp4"
                  completion:completion];
        }
    }];
    
    
}

//- (void)uploadMP4VideoData:(NSData *)fileData key:(NSString *)key completion:(void (^)(NSString *videoS3URL))completion {
//    
//    _s3 = [[AmazonS3Client alloc] initWithAccessKey:kTSJavelinS3UploadManagerDevelopmentAccessKey
//                                      withSecretKey:kTSJavelinS3UploadManagerDevelopmentSecretKey];
//    _s3.timeout = 240;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:key
//                                                                              inBucket:kTSJavelinS3UploadManagerDevelopmentBucketName];
//        // Make the object publicly readable
//        putObjectRequest.cannedACL = [S3CannedACL publicRead];
//        putObjectRequest.contentType = @"video/mp4";
//        putObjectRequest.data = fileData;
//        //putObjectRequest.delegate = self;
//        
//        // Put the video data into the specified s3 bucket and object.
//        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:putObjectRequest];
//        if (putObjectResponse.error != nil) {
//            NSLog(@"Error: %@", putObjectResponse.error);
//            if (completion) {
//                completion(nil);
//            }
//        }
//        else {
//            NSLog(@"The video was successfully uploaded.");
//            if (completion) {
//                completion([NSString stringWithFormat:@"http://%@.s3.amazonaws.com/%@", kTSJavelinS3UploadManagerDevelopmentBucketName, key]);
//            }
//        }
//    });
//}

//- (void)uploadAudioData:(NSData *)fileData key:(NSString *)key completion:(void (^)(NSString *audioS3URL))completion {
//    [AmazonLogger verboseLogging];
//    _s3 = [[AmazonS3Client alloc] initWithAccessKey:kTSJavelinS3UploadManagerDevelopmentAccessKey
//                                      withSecretKey:kTSJavelinS3UploadManagerDevelopmentSecretKey];
//    _s3.timeout = 240;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:key
//                                                                              inBucket:kTSJavelinS3UploadManagerDevelopmentBucketName];
//        // Make the object publicly readable
//        putObjectRequest.cannedACL = [S3CannedACL publicRead];
//        putObjectRequest.contentType = @"audio/aac";
//        putObjectRequest.data = fileData;
//        //putObjectRequest.delegate = self;
//        
//        // Put the video data into the specified s3 bucket and object.
//        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:putObjectRequest];
//        if (putObjectResponse.error != nil) {
//            NSLog(@"Error: %@", putObjectResponse.error);
//            if (completion) {
//                completion(nil);
//            }
//        }
//        else {
//            NSLog(@"The audio was successfully uploaded.");
//            if (completion) {
//                completion([NSString stringWithFormat:@"http://%@.s3.amazonaws.com/%@", kTSJavelinS3UploadManagerDevelopmentBucketName, key]);
//            }
//        }
//    });
//}


//#pragma mark - AmazonServiceRequestDelegate methods
//
//- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
//    NSLog(@"%@", error);
//}
//
//- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
//    NSLog(@"%@", response);
//}

@end
