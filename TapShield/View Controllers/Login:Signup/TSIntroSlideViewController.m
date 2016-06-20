//
//  TSIntroSlideViewController.m
//  TapShield
//
//  Created by Adam Share on 4/29/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSIntroSlideViewController.h"

#define PAGE2 @"One tap of the ‘Alert’ button will summon help from authorities. This will send your GPS location and profile info to dispatchers.”\n\nThe app will also automatically call the authorities in your area."

#define PAGE3 @"Going on a run while listening to music?\n\nTurn on Yank™ for an added layer of security. TapShield will automatically send an ‘Alert’ if headphones are pulled out of your device on purpose or by force. Don’t worry; you’ll have 10 seconds to disarm the ‘Alert’!"

#define PAGE4 @"Walk with an Entourage™\n\nSend friends your route before you go to let them know you're on the way.\n\n If you don't arrive in time, your safety network is automatically notified."

#define PAGE5 @"If your college subscribes to TapShield, safety alerts originating from inside school boundaries are routed to\ncampus dispatchers."

#define PAGE6 @"If you use TapShield outside of campus boundaries, the app will automatically dial 9-1-1, and authorities in your\nregion are notified."

@interface TSIntroSlideViewController ()

@end

@implementation TSIntroSlideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self pageNumber:_pageNumber];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPageNumber:(NSUInteger)pageNumber {
    _pageNumber = pageNumber;
}

- (void)pageNumber:(NSUInteger)page {
    
    _imageView.image = [self imageForPage:page];
    _imageView.contentMode = UIViewContentModeCenter;
    _label.text = [self textForPage:page];
}

- (UIImage *)imageForPage:(NSUInteger)page {
    
    NSString *imageName = [NSString stringWithFormat:@"slide_%lu", (unsigned long)page];
    
    return [UIImage imageNamed:imageName];
}

- (NSString *)textForPage:(NSUInteger)page {
    
    switch (page) {
        case 2:
            return PAGE2;
            break;
        case 3:
            return PAGE3;
            break;
        case 4:
            return PAGE4;
            break;
        case 5:
            return PAGE5;
            break;
        case 6:
            return PAGE6;
            break;
            
        default: return nil;
            break;
    }
}




@end
