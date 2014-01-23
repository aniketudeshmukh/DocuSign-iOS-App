//
//  WebViewController.m
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "WebViewController.h"
#import "DocuSignClient.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	DocuSignClient * client = [DocuSignClient sharedInstance];
    [client getRecipientViewURLForEnvelopeId:self.item.envelopeId onCompletion:^(NSString *receipientViewURL, NSError *error) {
        if (!error) {
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:receipientViewURL]];
            [request setAllHTTPHeaderFields:@{@"X-DocuSign-Authentication" : client.authenticationString, @"Content-Type" : @"application/json", @"Accept" : @"application/json"}];
            [self.webView loadRequest:request];
        }
        else {
            NSLog(@"Error : %@", error);
        }
    }];
}

@end
