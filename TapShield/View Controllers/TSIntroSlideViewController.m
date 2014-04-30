//
//  TSIntroSlideViewController.m
//  TapShield
//
//  Created by Adam Share on 4/29/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSIntroSlideViewController.h"

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
            return @"2";
            break;
        case 3:
            return @"3";
            break;
        case 4:
            return @"4";
            break;
        case 5:
            return @"5";
            break;
        case 6:
            return @"6";
            break;
            
        default: return nil;
            break;
    }
}




@end
