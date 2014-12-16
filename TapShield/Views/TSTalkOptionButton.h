//
//  TSTalkOptionButton.h
//  
//
//  Created by Adam Share on 11/6/14.
//
//

#import "TSBaseButton.h"

extern NSString * const kChatIcon;
extern NSString * const kPhoneIcon;
extern NSString * const k911Icon;

@interface TSTalkOptionButton : TSBaseButton

- (id)initWithFrame:(CGRect)frame imageType:(NSString *)type title:(NSString *)title;

@end
