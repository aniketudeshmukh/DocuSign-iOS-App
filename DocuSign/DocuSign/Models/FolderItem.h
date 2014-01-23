//
//  FolderItem.h
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FolderItem : NSObject
@property (nonatomic,copy) NSString * createdDateTime;
@property (nonatomic,copy) NSString * envelopeId;
@property (nonatomic,copy) NSString * envelopeUri;
@property (nonatomic,copy) NSString * expireDateTime;
@property (nonatomic,copy) NSString * ownerName;
@property (nonatomic,copy) NSString * recipientsUri;
@property (nonatomic,copy) NSString * senderEmail;
@property (nonatomic,copy) NSString * senderName;
@property (nonatomic,copy) NSString * senderUserId;
@property (nonatomic,copy) NSString * sentDateTime;
@property (nonatomic,copy) NSString * status;
@property (nonatomic,copy) NSString * subject;
-(void)setAttributes:(NSDictionary *)attributes;
@end
