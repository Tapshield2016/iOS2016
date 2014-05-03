//
//  TSIntroSlideViewController.m
//  TapShield
//
//  Created by Adam Share on 4/29/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSIntroSlideViewController.h"

#define PAGE2 @"One tap sends your real-time location and profile info to authorities\nwhen you hit 'Alert'.\n\n The app automatically launches a call to dispatchers, too."

#define PAGE3 @"Going on a run while listening to music?\n\n Turn on Yank to activate a safety alert when headphones are pulled from the device on purpose or by force."

#define PAGE4 @"Send friends your route before you go to let them know you're on the way.\n\n If you don't arrive in time, your safety network is automatically notified."

#define PAGE5 @"If your college subscribes to TapShield, safety alerts originating from inside school boundaries are routed to\ncampus dispatchers."

#define PAGE6 @"If you use TapShield outside of school boundaries, the app will automatically dial 9-1-1, and authorities in your\nregion are notified."

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

- (void)pageNumber:(int)page {
    
    _imageView.image = [self imageForPage:page];
    _imageView.contentMode = UIViewContentModeCenter;
    _label.text = [self textForPage:page];
}

- (UIImage *)imageForPage:(int)page {
    
    NSString *imageName = [NSString stringWithFormat:@"slide_%i", page];
    
    return [UIImage imageNamed:imageName];
}

- (NSString *)textForPage:(int)page {
    
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
