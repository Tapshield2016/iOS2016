//
//  TSJavelinS3UploadManager.h
//  Javelin
//
//  Created by Ben Boyd on 12/4/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "S3.h"
#import "AWSCore.h"

#ifdef APP_STORE
extern NSString * const kTSJavelinS3UploadManagerBucketName;
#else
extern NSString * const kTSJavelinS3UploadManagerBucketName;
#endif

@interface TSJavelinS3UploadManager : NSObject

@property (nonatomic, strong) AWSS3 *s3;

- (void)uploadUIImageToS3:(UIImage *)image imageName:(NSString *)imageName completion:(void (^)(NSString *imageS3URL))completion;
- (void)uploadUncompressedUIImageToS3:(UIImage *)image imageName:(NSString *)imageName completion:(void (^)(NSString *imageS3URL))completion;

// Uploads file to S3
- (void)uploadData:(NSData *)fileData key:(NSString *)key type:(NSString *)type completion:(void (^)(NSString *imageS3URL))completion;
//- (void)uploadMP4VideoData:(NSData *)fileData key:(NSString *)key completion:(void (^)(NSString *videoS3URL))completion;
//- (void)uploadAudioData:(NSData *)fileData key:(NSString *)key completion:(void (^)(NSString *audioS3URL))completion;

- (void)convertToMP4andUpload:(NSURL *)videoUrl completion:(void (^)(NSString *videoS3URL))completion;

@end
