//
//  TSGooglePlusWebView.m
//  TapShield
//
//  Created by Adam Share on 9/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSWebViewController.h"

@implementation TSWebViewController

+ (instancetype)webViewControllerWithURL:(NSURL *)url delegate:(id)delegate
{
    TSWebViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSWebViewController class])];
    viewController.delegate = delegate;
    viewController.url = url;
    
    return viewController;
}

+ (void)controller:(UIViewController *)viewcontroller presentWebViewControllerWithURL:(NSURL *)url delegate:(id)delegate {
    TSWebViewController *webView = [TSWebViewController webViewControllerWithURL:url delegate:delegate];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webView];
    [webView whiteNavigationBar];
    [webView.navigationController setNavigationBarHidden:NO];
    [viewcontroller presentViewController:nav animated:YES completion:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (IBAction)goBack:(id)sender {
    [_webView goBack];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    _webView.delegate = _delegate;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url] ;
    [_webView loadRequest: request];
}


- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
