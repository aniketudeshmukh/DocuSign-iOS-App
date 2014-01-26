//
//  DocuSignClient.h
//  DocuSign
//
//  Created by Aniket on 1/23/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef NS_ENUM(NSInteger, DSFolderType) {
    AwaitingMySignature = 0,
    Drafts,
    OutForSignature,
    Completed
};

@interface DocuSignClient : NSObject
@property (nonatomic, copy, readonly) NSString * authenticationString;
@property (nonatomic, readonly) User * currentUser;

+(instancetype)sharedInstance;

-(void)loginUser:(NSString *)user password:(NSString *) password onCompletion:(void(^)(NSError * error))completionHandler;

-(void)getEnvelopesFromFolder:(DSFolderType)folderType onCompletion:(void(^)(NSArray * array, NSError * error))completionHandler;

-(void)getAllTemplatesOnCompletion:(void(^)(NSArray * array, NSError * error))completionHandler;

-(void)getRecipientViewURLForEnvelopeId:(NSString *)envelopeId onCompletion:(void(^)(NSString * receipientViewURL, NSError * error))completionHandler;

-(void)sendRequestForSigningDocument:(NSString *)documentName documentPath:(NSString *)documentPath receipient:(NSString *)name email:(NSString *)email subject:(NSString *)subject emailBody:(NSString *)emailbody onCompletion:(void(^)(NSError * error))completionHandler;

-(void)sendRequestForSigningTemplateId:(NSString *)templateId receipient:(NSString *)name email:(NSString *)email subject:(NSString *)subject emailBody:(NSString *)emailbody onCompletion:(void(^)(NSError * error))completionHandler;

-(void)downloadAllDocumentsForEnvelopeId:(NSString *)envelopeId onCompletion:(void(^)(NSArray * downloadedDocuments, NSError * error))completionHandler;
@end
