//
//  SignatureRequestViewController.m
//  DocuSign
//
//  Created by Aniket Deshmukh on 24/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "SignatureRequestViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "DocuSignClient.h"
#import "TemplatesViewController.h"
#import "LocalDocumentsViewController.h"
#import "EnvelopeTemplate.h"
#import "LocalDocument.h"
#import "MBProgressHUD.h"

@interface SignatureRequestViewController ()<ABPeoplePickerNavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fileNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *documentTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *recipientTextField;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextView *emailBodyTextView;
@property (nonatomic, strong) EnvelopeTemplate * template;
@property (nonatomic, strong) LocalDocument * document;
@property (nonatomic, copy) NSString * recipientEmail;
- (IBAction)chooseFile:(id)sender;
- (IBAction)chooseRecipient:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;
@end

@implementation SignatureRequestViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.recipientTextField becomeFirstResponder];
}


#pragma mark - SignatureRequestViewController

-(void)configureView {
    if (self.signatureRequestType == UsingTemplate) {
        self.documentTypeLabel.text = @"Template:";
        self.fileNameTextField.placeholder = @"Choose your template";
    }
    else {
        self.documentTypeLabel.text = @"Document:";
        self.fileNameTextField.placeholder = @"Choose your document";
    }
    self.subjectTextField.text = [self defaultEmailSubject];
    self.emailBodyTextView.text = [self defaultEmailBody];
}

-(NSString *)defaultEmailSubject {
    return [NSString stringWithFormat:@"Please DocuSign this document %@",self.fileNameTextField.text];
}

-(NSString *)defaultEmailBody {
    return [NSString stringWithFormat:@"Hello,\n\n%@ has sent you a new DocuSign document to view and sign.\n\n\nThanks,\n%@",[DocuSignClient sharedInstance].currentUser.userName,[DocuSignClient sharedInstance].currentUser.userName];
}

- (IBAction)chooseRecipient:(id)sender {
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    [peoplePicker setPeoplePickerDelegate:self];
    [peoplePicker setDisplayedProperties:[NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]]];
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)send:(id)sender {
    //Validation
    if (self.recipientTextField.text == nil || [self.recipientTextField.text isEqualToString:@""] ||
        self.subjectTextField.text == nil || [self.subjectTextField.text isEqualToString:@""] ||
        self.emailBodyTextView.text == nil || [self.emailBodyTextView.text isEqualToString:@""] ||
        (self.template == nil && self.document == nil)) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Request" message:@"All details are mandatory. Please complete the request." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else {
        //Send Request
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Sending Request...";
        DocuSignClient * client = [DocuSignClient sharedInstance];
        if (self.signatureRequestType == UsingTemplate) {
            //Send Template For Signing
            NSString * templateId = self.template.templateId;
            NSString * recipient = self.recipientTextField.text;
            NSString * subject = self.subjectTextField.text;
            NSString * body = self.emailBodyTextView.text;
            [client sendRequestForSigningTemplateId:templateId recipient:recipient email:self.recipientEmail subject:subject emailBody:body onCompletion:^(NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
                else {
                    //Signature Request Sent Successfully.
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
        else {
            //Send Document For Signing
            NSString * documentName = self.fileNameTextField.text;
            NSString * recipient = self.recipientTextField.text;
            NSString * subject = self.subjectTextField.text;
            NSString * body = self.emailBodyTextView.text;
            [client sendRequestForSigningDocument:documentName documentPath:self.document.path recipient:recipient email:self.recipientEmail subject:subject emailBody:body onCompletion:^(NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
                else {
                    //Signature Request Sent Successfully.
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }
}

- (IBAction)chooseFile:(id)sender {
    if (self.signatureRequestType == UsingTemplate) {
        [self performSegueWithIdentifier:@"ShowTemplates" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"ShowLocalDcouments" sender:self];
    }
}


#pragma mark - ABPeoplePickerNavigationControllerDelegate

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
    self.recipientTextField.text = personName;

    ABMultiValueRef multiEmail = ABRecordCopyValue(person, property);
    self.recipientEmail = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multiEmail, identifier);
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    return NO;
}


#pragma mark - Navigation

-(IBAction)unwindToSignatureRequestViewController:(UIStoryboardSegue *)unwindSegue {
    NSLog(@"Sender: %@",unwindSegue);
    if ([unwindSegue.identifier isEqualToString:@"TemplateSelected"]) {
        if([unwindSegue.sourceViewController isKindOfClass:[TemplatesViewController class]]) {
            TemplatesViewController * sourceVC = (TemplatesViewController *)unwindSegue.sourceViewController;
            NSIndexPath * selectedIndexPath = [sourceVC.tableView indexPathForSelectedRow];
            if (selectedIndexPath) {
                self.template = sourceVC.templates[selectedIndexPath.row];
                self.fileNameTextField.text = self.template.name;
                //Set email subject defined in template.
                if (self.template.emailSubject && ![self.template.emailSubject isEqualToString:@""]) {
                    self.subjectTextField.text = self.template.emailSubject;
                }
                else {
                    self.subjectTextField.text = [self defaultEmailSubject];
                }
                //Set email body defined in template.
                if (self.template.emailBlurb && ![self.template.emailBlurb isEqualToString:@""]) {
                    self.emailBodyTextView.text = self.template.emailBlurb;
                }
                else {
                    self.emailBodyTextView.text = [self defaultEmailBody];
                }
            }
        }
    }
    else if ([unwindSegue.identifier isEqualToString:@"DocumentSelected"]) {
        if([unwindSegue.sourceViewController isKindOfClass:[LocalDocumentsViewController class]]) {
            LocalDocumentsViewController * sourceVC = (LocalDocumentsViewController *)unwindSegue.sourceViewController;
            NSIndexPath * selectedIndexPath = [sourceVC.tableView indexPathForSelectedRow];
            if (selectedIndexPath) {
                self.document = sourceVC.documents[selectedIndexPath.row];
                self.fileNameTextField.text = self.document.name;
            }
        }
    }
}

@end
