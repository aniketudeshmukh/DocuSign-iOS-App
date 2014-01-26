//
//  EnvelopeTemplate.h
//  DocuSign
//
//  Created by Aniket on 1/26/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnvelopeTemplate : NSObject
@property (nonatomic,copy) NSString * description;
@property (nonatomic,copy) NSString * emailBlurb;
@property (nonatomic,copy) NSString * emailSubject;
@property (nonatomic,copy) NSString * folderId;
@property (nonatomic,copy) NSString * folderName;
@property (nonatomic,copy) NSString * folderUri;
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSString * lastModified;
@property (nonatomic,copy) NSNumber * pageCount;
@property (nonatomic,copy) NSString * password;
@property (nonatomic,copy) NSString * shared;
@property (nonatomic,copy) NSString * templateId;
@property (nonatomic,copy) NSString * uri;
-(void)setAttributes:(NSDictionary *)attributes;
@end
