//
//  SignatureRequestViewController.h
//  DocuSign
//
//  Created by Aniket Deshmukh on 24/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SignatureRequestType) {
    UsingTemplate,
    UsingDocument
};

@interface SignatureRequestViewController : UITableViewController

/* View will be configured as per the Signature Request Type supplied */
@property (nonatomic, assign) SignatureRequestType signatureRequestType;

-(IBAction)unwindToSignatureRequestViewController:(UIStoryboardSegue *)unwindSegue;

@end
