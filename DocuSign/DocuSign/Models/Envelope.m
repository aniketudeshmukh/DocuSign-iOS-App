//
//  Envelope.m
//  DocuSign
//
//  Created by Aniket on 1/27/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "Envelope.h"

@implementation Envelope
-(void)setAttributes:(NSDictionary *)attributes {
    self.certificateUri = attributes[@"certificateUri"];
    self.certificateUri = attributes[@"certificateUri"];
    self.customFieldsUri = attributes[@"customFieldsUri"];
    self.documentsCombinedUri = attributes[@"documentsCombinedUri"];
    self.documentsUri = attributes[@"documentsUri"];
    self.emailSubject = attributes[@"emailSubject"];
    self.envelopeId = attributes[@"envelopeId"];
    self.envelopeUri = attributes[@"envelopeUri"];
    self.notificationUri = attributes[@"notificationUri"];
    self.recipientsUri = attributes[@"recipientsUri"];
    self.status = attributes[@"status"];
    self.statusChangedDateTime = attributes[@"statusChangedDateTime"];
    self.createdDateTime = attributes[@"createdDateTime"];
    self.deliveredDateTime = attributes[@"deliveredDateTime"];
    self.sentDateTime = attributes[@"sentDateTime"];
    self.completedDateTime = attributes[@"completedDateTime"];
}

@end
