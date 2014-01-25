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

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
//        self.webView.clipsToBounds = NO;
    }
    else {
        DocuSignClient * client = [DocuSignClient sharedInstance];
        [client getRecipientViewURLForEnvelopeId:self.item.envelopeId onCompletion:^(NSString *receipientViewURL, NSError *error) {
            if (!error) {
                NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:receipientViewURL]];
                [request setAllHTTPHeaderFields:@{@"X-DocuSign-Authentication" : client.authenticationString, @"Content-Type" : @"application/json", @"Accept" : @"application/json"}];
                [self.webView loadRequest:request];
            }
            else {
                NSLog(@"Error : %@", error);
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            }
        }];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Request: %@", request);
    NSLog(@"Navigation Type: %d", navigationType);
    
    if ([request.URL.absoluteString isEqualToString:@"http://done/?event=viewing_complete"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

@end
