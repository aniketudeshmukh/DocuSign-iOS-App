//
//  EnvelopeTemplate.m
//  DocuSign
//
//  Created by Aniket on 1/26/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "EnvelopeTemplate.h"

@implementation EnvelopeTemplate

-(void)setAttributes:(NSDictionary *)attributes {
    self.description = attributes[@"description"];
    self.emailBlurb = attributes[@"emailBlurb"];
    self.emailSubject = attributes[@"emailSubject"];
    self.folderId = attributes[@"folderId"];
    self.folderName = attributes[@"folderName"];
    self.folderUri = attributes[@"folderUri"];
    self.lastModified = attributes[@"lastModified"];
    self.name = attributes[@"name"];
    self.pageCount = attributes[@"pageCount"];
    self.password = attributes[@"password"];
    self.shared = attributes[@"shared"];
    self.templateId = attributes[@"templateId"];
    self.uri = attributes[@"uri"];
}

@end
