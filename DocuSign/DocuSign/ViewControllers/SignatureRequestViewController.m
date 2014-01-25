//
//  SignatureRequestViewController.m
//  DocuSign
//
//  Created by Aniket Deshmukh on 24/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "SignatureRequestViewController.h"
#import "DocuSignClient.h"
#import <AddressBookUI/AddressBookUI.h>

@interface SignatureRequestViewController ()<ABPeoplePickerNavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fileNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *receipientTextField;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextView *emailBodyTextView;
- (IBAction)chooseFile:(id)sender;
- (IBAction)chooseReceipient:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;
@end

@implementation SignatureRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.subjectTextField.text = [NSString stringWithFormat:@"Please DocuSign this document %@",self.fileNameTextField.text];
    self.emailBodyTextView.text = [NSString stringWithFormat:@"Hello,\n\n%@ has sent you a new DocuSign document to view and sign.\n\n\nThanks,\n%@",[DocuSignClient sharedInstance].currentUser.userName,[DocuSignClient sharedInstance].currentUser.userName];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.receipientTextField becomeFirstResponder];
}


- (IBAction)chooseReceipient:(id)sender {
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    [peoplePicker setPeoplePickerDelegate:self];
    [peoplePicker setDisplayedProperties:[NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]]];
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)send:(id)sender {
    DocuSignClient * client = [DocuSignClient sharedInstance];
    NSString * documentName = self.fileNameTextField.text;
    NSString * recipient = self.receipientTextField.text;
    NSString * subject = self.receipientTextField.text;
    NSString * body = self.receipientTextField.text;
    [client sendRequestForSigningDocument:documentName receipient:recipient email:recipient subject:subject emailBody:body onCompletion:^(NSString *receipientViewURL, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

- (IBAction)chooseFile:(id)sender {
}

-(IBAction)unwindToSignatureRequestViewController:(UIStoryboardSegue *)unwindSegue {
    NSLog(@"Sender: %@",unwindSegue);
    if ([unwindSegue.identifier isEqualToString:@"TemplateSelected"]) {
        if([unwindSegue.sourceViewController isKindOfClass:[UITableViewController class]]) {
            UITableViewController * sourceVC = (UITableViewController *)unwindSegue.sourceViewController;
            self.fileNameTextField.text = [sourceVC.tableView cellForRowAtIndexPath:[sourceVC.tableView indexPathForSelectedRow]].textLabel.text;
        }
    }
}

#pragma mark ABPeoplePickerNavigationControllerDelegate
-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    NSString * firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString * lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString * personName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    self.receipientTextField.text = personName;
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
    }];
    return NO;
}

@end
