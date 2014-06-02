//
//  TSJavelinS3UploadManager.h
//  Javelin
//
//  Created by Ben Boyd on 12/4/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AmazonS3Client.h>

@interface TSJavelinS3UploadManager : NSObject <AmazonServiceRequestDelegate>

@property (nonatomic, strong) AmazonS3Client *s3;

- (void)uploadUIImageToS3:(UIImage *)image imageName:(NSString *)imageName completion:(void (^)(NSString *imageS3URL))completion;
- (void)uploadUncompressedUIImageToS3:(UIImage *)image imageName:(NSString *)imageName completion:(void (^)(NSString *imageS3URL))completion;

// Uploads file to S3
- (void)uploadImageData:(NSData *)fileData key:(NSString *)key completion:(void (^)(NSString *imageS3URL))completion;
- (void)uploadVideoData:(NSData *)fileData key:(NSString *)key completion:(void (^)(NSString *videoS3URL))completion;

@end
