//
//  TSCircularControl.h
//  TapShield
//
//  Created by Adam Share on 4/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BACKGROUND_WIDTH 3
#define LINE_WIDTH 3
#define SELECTOR_SIZE 20

@interface TSCircularControl : UIControl

@property (assign, nonatomic) float angle;

- (void)setDegreeForStartTime:(NSTimeInterval)startTime currentTime:(NSTimeInterval)currentTime;

@end
