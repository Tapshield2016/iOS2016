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
#import "TSLogoImageView.h"
#import "UIImage+Resize.h"

#define MESSAGE_FONT_SIZE 17
#define MESSAGE_INSET_HORIZONTAL 5
#define MESSAGE_INSET_VERTICAL 5
#define ROUND_RECT_MAX_WIDTH 240
#define ROUND_RECT_X_MIN 15
#define ROUND_RECT_Y_MIN 10
#define IMAGE_SIZE 40
#define STATUS_FONT_SIZE 8

NSString * const TSChatMessageCellIdentifierUser = @"TSChatMessageCellIdentifierUser";
NSString * const TSChatMessageCellIdentifierDispatcher = @"TSChatMessageCellIdentifierDispatcher";

@implementation TSChatMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        if ([reuseIdentifier isEqualToString:TSChatMessageCellIdentifierUser]) {
            [self userFormat];
        }
        else {
            [self dispatcherFormat];
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
    _messageLabel.text = chatMessage.message;
    
    if (chatMessage.senderID != [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].identifier) {
        
        [self setDispatcherMessage:chatMessage];
        return;
    }
    
    CGSize messageSize = [TSChatMessageCell sizeOfChatMessage:chatMessage.message];
    CGRect roundRectFrame = _roundRectView.frame;
    roundRectFrame.size.height = messageSize.height + MESSAGE_INSET_VERTICAL*2;
    roundRectFrame.size.width = messageSize.width + MESSAGE_INSET_HORIZONTAL*2;
    if (roundRectFrame.size.width > ROUND_RECT_MAX_WIDTH - MESSAGE_INSET_HORIZONTAL*2) {
        roundRectFrame.size.width = ROUND_RECT_MAX_WIDTH;
    }
    roundRectFrame.origin.x = ROUND_RECT_X_MIN + ROUND_RECT_MAX_WIDTH - roundRectFrame.size.width;
    _roundRectView.frame = roundRectFrame;
    
    CGRect frame = _messageLabel.frame;
    frame.size.height = roundRectFrame.size.height;
    frame.size.width = messageSize.width;
    _messageLabel.frame = frame;
    
    
    _statusLabel.text =  [chatMessage chatMessageStatusToString:chatMessage.status];
    CGRect statusFrame = _statusLabel.frame;
    statusFrame.origin.y = _roundRectView.frame.origin.y + _roundRectView.frame.size.height;
    _statusLabel.frame = statusFrame;
}

- (void)setDispatcherMessage:(TSJavelinAPIChatMessage *)chatMessage {
    
    CGSize messageSize = [TSChatMessageCell sizeOfChatMessage:chatMessage.message];
    CGRect roundRectFrame = _roundRectView.frame;
    roundRectFrame.size.height = messageSize.height + MESSAGE_INSET_VERTICAL*2;
    roundRectFrame.size.width = messageSize.width + MESSAGE_INSET_HORIZONTAL*2;
    if (roundRectFrame.size.width > ROUND_RECT_MAX_WIDTH - MESSAGE_INSET_HORIZONTAL*2) {
        roundRectFrame.size.width = ROUND_RECT_MAX_WIDTH;
    }
    _roundRectView.frame = roundRectFrame;
    
    CGRect frame = _messageLabel.frame;
    frame.size.height = roundRectFrame.size.height;
    frame.size.width = messageSize.width;
    _messageLabel.frame = frame;
}

- (void)userFormat {
    
//Round Rect shape
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    
    _roundRectView = [[UIView alloc] initWithFrame:CGRectMake(ROUND_RECT_X_MIN, ROUND_RECT_Y_MIN, ROUND_RECT_MAX_WIDTH, 36)];
    _roundRectView.backgroundColor = color;
    _roundRectView.layer.cornerRadius = 5.0f;
    _roundRectView.layer.masksToBounds = YES;

    
//Triangle shape
    
    float triangleHeight = 12;
    _triangleView = [[UIView alloc] initWithFrame:CGRectMake(_roundRectView.frame.size.width + _roundRectView.frame.origin.x, ROUND_RECT_X_MIN + MESSAGE_INSET_VERTICAL/2, triangleHeight/2, triangleHeight)];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,0.0,0.0);
    CGPathAddLineToPoint(path, NULL, triangleHeight/2, triangleHeight/2);
    CGPathAddLineToPoint(path, NULL, 0, triangleHeight);
    CGPathCloseSubpath(path);
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:path];
    [shapeLayer setFillColor:color.CGColor];
    [shapeLayer setBounds:CGRectMake(0.0f, 0.0f, triangleHeight/2, triangleHeight)];
    [shapeLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [shapeLayer setPosition:CGPointMake(0.0f, 0.0f)];
    [_triangleView.layer addSublayer:shapeLayer];
    
    CGPathRelease(path);
  
    
//Message Label
    
    float labelInset = 5.0;
    
    CGRect frame = _roundRectView.bounds;
    frame.origin.x = labelInset;
    frame.size.width -= labelInset*2;
    _messageLabel = [[UILabel alloc] initWithFrame:frame];
    _messageLabel.numberOfLines = 0;
    _messageLabel.textColor = [TSColorPalette whiteColor];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textAlignment = NSTextAlignmentLeft;
    _messageLabel.font = [TSFont fontWithName:kFontWeightLight size:MESSAGE_FONT_SIZE];
    
    
    
//ImageView
    
    _userImageView = [[TSRoundUserImageView alloc] initWithFrame:CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE)];
    UIImage *image = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].userProfile.profileImage;
    if (image) {
        _userImageView.image = image;
    }
    CGRect imageViewFrame = _userImageView.frame;
    float maxBubbleWidth = ROUND_RECT_X_MIN + ROUND_RECT_MAX_WIDTH + _triangleView.frame.size.width;
    imageViewFrame.origin.x = maxBubbleWidth + (self.frame.size.width - maxBubbleWidth - imageViewFrame.size.width)/2;
    imageViewFrame.origin.y = ROUND_RECT_Y_MIN;
    _userImageView.frame = imageViewFrame;
    
    
//Status Label
    
    _statusLabel = [[UILabel alloc] initWithFrame:_roundRectView.frame];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textColor = [TSColorPalette darkGrayColor];
    _statusLabel.textAlignment = NSTextAlignmentRight;
    _statusLabel.font = [TSFont fontWithName:kFontWeightLight size:STATUS_FONT_SIZE];
    
    CGRect statusFrame = _roundRectView.frame;
    statusFrame.origin.y = statusFrame.origin.y + statusFrame.size.height;
    statusFrame.size.height = ROUND_RECT_Y_MIN;
    _statusLabel.frame = statusFrame;
    
//Subview Hierarchy
    
    [_roundRectView addSubview:_messageLabel];
    [self addSubview:_statusLabel];
    [self addSubview:_triangleView];
    [self addSubview:_roundRectView];
    [self addSubview:_userImageView];
}

- (void)dispatcherFormat {
    
    //Round Rect shape
    UIColor *color = [TSColorPalette lightTextColor];
    
    _roundRectView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - ROUND_RECT_X_MIN - ROUND_RECT_MAX_WIDTH, ROUND_RECT_Y_MIN, ROUND_RECT_MAX_WIDTH, 36)];
    _roundRectView.backgroundColor = color;
    _roundRectView.layer.cornerRadius = 5.0f;
    _roundRectView.layer.masksToBounds = YES;
    
    
    //Triangle shape
    
    float triangleHeight = 12;
    _triangleView = [[UIView alloc] initWithFrame:CGRectMake(_roundRectView.frame.origin.x - triangleHeight/2, ROUND_RECT_X_MIN + MESSAGE_INSET_VERTICAL/2, triangleHeight/2, triangleHeight)];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,triangleHeight/2,0.0);
    CGPathAddLineToPoint(path, NULL, 0.0, triangleHeight/2);
    CGPathAddLineToPoint(path, NULL, triangleHeight/2, triangleHeight);
    CGPathCloseSubpath(path);
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:path];
    [shapeLayer setFillColor:color.CGColor];
    [shapeLayer setBounds:CGRectMake(0.0f, 0.0f, triangleHeight/2, triangleHeight)];
    [shapeLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [shapeLayer setPosition:CGPointMake(0.0f, 0.0f)];
    [_triangleView.layer addSublayer:shapeLayer];
    
    CGPathRelease(path);
    
    
    //Message Label
    
    float labelInset = 5.0;
    
    CGRect frame = _roundRectView.bounds;
    frame.origin.x = labelInset;
    frame.size.width -= labelInset*2;
    _messageLabel = [[UILabel alloc] initWithFrame:frame];
    _messageLabel.numberOfLines = 0;
    _messageLabel.textColor = [TSColorPalette darkGrayColor];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textAlignment = NSTextAlignmentLeft;
    _messageLabel.font = [TSFont fontWithName:kFontWeightLight size:MESSAGE_FONT_SIZE];
    
    
    
    //ImageView
    
    _userImageView = [[TSRoundUserImageView alloc] initWithFrame:CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE)];
    UIImage *image = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.theme.smallLogo;
    if (image) {
        _userImageView.contentMode = UIViewContentModeScaleAspectFit;
        _userImageView.image = image;
    }
    else {
        _userImageView.image = [[UIImage imageNamed:TSLogoImageViewSmallTapShieldLogo] resizeToSize:CGSizeMake(_userImageView.frame.size.width*.75, _userImageView.frame.size.height*.75)];
        _userImageView.contentMode = UIViewContentModeCenter;
    }
    CGRect imageViewFrame = _userImageView.frame;
    imageViewFrame.origin.x = (_roundRectView.frame.origin.x - imageViewFrame.size.width)/2;
    imageViewFrame.origin.y = ROUND_RECT_Y_MIN;
    _userImageView.frame = imageViewFrame;
    _userImageView.backgroundColor = [UIColor whiteColor];
    
    //Subview Hierarchy
    
    [_roundRectView addSubview:_messageLabel];
    [self addSubview:_triangleView];
    [self addSubview:_roundRectView];
    [self addSubview:_userImageView];
}



+ (CGFloat)heightForChatCellAtIndexPath:(NSIndexPath *)indexPath {
    
    TSJavelinAPIChatMessage *chatMessage = [[TSJavelinAPIClient sharedClient] chatManager].chatMessages.allMessages[indexPath.row];
    CGFloat height;
    float buffer = MESSAGE_INSET_VERTICAL*2 + ROUND_RECT_Y_MIN*2;
    
    height = [TSChatMessageCell heightOfChatMessage:chatMessage.message] + buffer;
    
    return height;
}

+ (CGSize)sizeOfChatMessage:(NSString *)message {
    
    UIFont *font = [TSFont fontWithName:kFontWeightLight size:MESSAGE_FONT_SIZE];
    CGSize size = [TSUtilities text:message sizeWithFont:font constrainedToSize:CGSizeMake(ROUND_RECT_MAX_WIDTH - MESSAGE_INSET_HORIZONTAL*2, INFINITY)];
    return size;
}

+ (float)heightOfChatMessage:(NSString *)message {
    
    return [TSChatMessageCell sizeOfChatMessage:message].height;
}

@end
