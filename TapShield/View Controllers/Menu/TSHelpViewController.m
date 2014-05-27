//
//  TSHelpViewController.m
//  TapShield
//
//  Created by Ben Boyd on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHelpViewController.h"

@interface TSHelpViewController ()

@end

@implementation TSHelpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString *infoUrl = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.infoUrl;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:infoUrl]];
    [_webView loadRequest: request];
    _webView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
    
    if ([request.URL isEqual:[NSURL URLWithString:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.infoUrl]] &&
        navigationType == UIWebViewNavigationTypeBackForward) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (IBAction)goBack:(id)sender {
    [_webView goBack];
}
@end
