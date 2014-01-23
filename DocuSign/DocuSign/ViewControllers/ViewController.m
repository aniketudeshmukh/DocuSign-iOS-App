//
//  ViewController.m
//  DocuSign
//
//  Created by Aniket on 1/22/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "ViewController.h"
#import "DocuSignClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    DocuSignClient * client = [DocuSignClient sharedInstance];
    [client loginUser:@"aniketudeshmukh@gmail.com" password:@"Ani216ket" onCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Login Failed!");
            NSLog(@"Error Code : %d",error.code);
            NSLog(@"Reason : %@",error.localizedDescription);
        }
        else {
            NSLog(@"Login Successful");
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
