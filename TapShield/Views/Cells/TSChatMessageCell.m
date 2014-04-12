//
//  TSChatMessageCell.m
//  TapShield
//
//  Created by Adam Share on 4/12/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSChatMessageCell.h"
#import "TSJavelinChatManager.h"
#import "TSUtilities.h"

#define MESSAGE_FONT_SIZE 17

NSString * const TSChatMessageCellIdentifierUser = @"TSChatMessageCellIdentifierUser";
NSString * const TSChatMessageCellIdentifierDispatcher = @"TSChatMessageCellIdentifierDispatcher";

@implementation TSChatMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if ([reuseIdentifier isEqualToString:TSChatMessageCellIdentifierUser]) {
            [self rightArrowTriangle];
        }
        else {
            
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setChatMessage:(TSJavelinAPIChatMessage *)chatMessage {
    
    _chatMessage = chatMessage;
    
    
}



- (void)rightArrowTriangle {
    
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    
    _roundRectView = [[UIView alloc] initWithFrame:CGRectMake(15, 5, 227, 36)];
    _roundRectView.backgroundColor = color;
    _roundRectView.layer.cornerRadius = 5.0f;
    _roundRectView.layer.masksToBounds = YES;
    
    float triangleHeight = 14;
    _triangleView = [[UIView alloc] initWithFrame:CGRectMake(_roundRectView.frame.size.width + _roundRectView.frame.origin.x, triangleHeight, triangleHeight/2, triangleHeight)];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,0.0,0.0);
    CGPathAddLineToPoint(path, NULL, triangleHeight/2, triangleHeight/2);
    CGPathAddLineToPoint(path, NULL, 0, triangleHeight);
    CGPathCloseSubpath(path);
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:path];
    [shapeLayer setFillColor:[[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor]];
    [shapeLayer setBounds:CGRectMake(0.0f, 0.0f, 5.0f, 5.0f)];
    [shapeLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [shapeLayer setPosition:CGPointMake(0.0f, 0.0f)];
    [_triangleView.layer addSublayer:shapeLayer];
    
    CGPathRelease(path);
    
    [self addSubview:_triangleView];
    [self addSubview:_roundRectView];
}

+ (CGFloat)heightForChatCellAtIndexPath:(NSIndexPath *)indexPath {
    
    TSJavelinAPIChatMessage *chatMessage = [[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages[indexPath.row];
    CGFloat height;
    float buffer = 15;
    
    height = [TSChatMessageCell heightOfChatMessage:chatMessage.message] + buffer*2;
    
    return height;
}

+ (float)heightOfChatMessage:(NSString *)message {
    
    float height;
    UIFont *font = [TSRalewayFont fontWithName:kFontRalewayRegular size:MESSAGE_FONT_SIZE];
    CGSize size = [TSUtilities text:message sizeWithFont:font constrainedToSize:CGSizeMake(237, INFINITY)];
    
    height = size.height;
    
    return height;
}

@end
