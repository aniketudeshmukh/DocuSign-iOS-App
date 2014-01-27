//
//  WebViewController.m
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "WebViewController.h"
#import "DocuSignClient.h"
#import "MBProgressHUD.h"

@interface WebViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation WebViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    DocuSignClient * client = [DocuSignClient sharedInstance];
    [client getRecipientViewURLForEnvelopeId:self.envelopeId onCompletion:^(NSString *recipientViewURL, NSError *error) {
        if (!error) {
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:recipientViewURL]];
            [request setAllHTTPHeaderFields:@{@"X-DocuSign-Authentication" : client.authenticationString, @"Content-Type" : @"application/json", @"Accept" : @"application/json"}];
            [self.webView loadRequest:request];
        }
        else {
            NSLog(@"Error : %@", error);
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        }
    }];
}


#pragma mark - UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Request: %@", request);
    NSLog(@"Navigation Type: %d", navigationType);
    
    if ([request.URL.host isEqualToString:@"done"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

@end
