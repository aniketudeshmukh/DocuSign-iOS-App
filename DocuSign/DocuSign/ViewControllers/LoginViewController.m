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
- (IBAction)moveToNextTextField:(UITextField *)sender;
@end

@implementation LoginViewController

#pragma mark - UIViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.passwordTextField.text = @"";
}


#pragma mark - LoginViewController
- (IBAction)moveToNextTextField:(UITextField *)sender {
    [self.passwordTextField becomeFirstResponder];
}

- (IBAction)login {
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];

    NSString * user = self.userTextField.text;
    NSString * password = self.passwordTextField.text;

    if (!user || [user isEqualToString:@""] || !password || [password isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Invalid Credentials" message:@"User and/or password cannot be blank. Please enter valid user and password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    else {
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Logging In...";

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
}



@end
