//
//  LoginViewController.m
//  DocuSign
//
//  Created by Aniket on 1/23/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "LoginViewController.h"
#import "DocuSignClient.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)login;
@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.passwordTextField.text = @"";
}


- (IBAction)login {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging In...";
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];

    NSString * user = self.userTextField.text;
    NSString * password = self.passwordTextField.text;

    DocuSignClient * client = [DocuSignClient sharedInstance];
    [client loginUser:user password:password onCompletion:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        if (error) {
            NSLog(@"Login Failed!");
            NSLog(@"Error Code : %d",error.code);
            NSLog(@"Reason : %@",error.localizedDescription);
            [[[UIAlertView alloc] initWithTitle:@"Login Failed!" message:[NSString stringWithFormat:@"Error Code: %d\n Reason: %@", error.code,error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        else {
            NSLog(@"Login Successful");
            [self performSegueWithIdentifier:@"ShowMainViewController" sender:self];
        }
    }];
}
@end
