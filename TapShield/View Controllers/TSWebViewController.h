//
//  TSGooglePlusWebView.h
//  TapShield
//
//  Created by Adam Share on 9/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNavigationViewController.h"

@interface TSWebViewController : TSNavigationViewController

+ (instancetype)webViewControllerWithURL:(NSURL *)url delegate:(id)delegate;
+ (void)controller:(UIViewController *)viewcontroller presentWebViewControllerWithURL:(NSURL *)url delegate:(id)delegate;


@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) id delegate;

- (IBAction)goBack:(id)sender;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButton;

@end
