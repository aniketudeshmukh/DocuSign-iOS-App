//
//  FolderItem.m
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "FolderItem.h"

@implementation FolderItem

-(void)setAttributes:(NSDictionary *)attributes {
    self.createdDateTime = attributes[@"createdDateTime"];
    self.envelopeId = attributes[@"envelopeId"];
    self.envelopeUri = attributes[@"envelopeUri"];
    self.expireDateTime = attributes[@"expireDateTime"];
    self.ownerName = attributes[@"ownerName"];
    self.recipientsUri = attributes[@"recipientsUri"];
    self.senderEmail = attributes[@"senderEmail"];
    self.senderName = attributes[@"senderName"];
    self.senderUserId = attributes[@"senderUserId"];
    self.sentDateTime = attributes[@"sentDateTime"];
    self.status = attributes[@"status"];
    self.subject = attributes[@"subject"];
}

@end
