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

/* Returns Singleton instance of this class */
+(instancetype)sharedInstance;

/* Call this method for logging in to DocuSign API */
-(void)loginUser:(NSString *)user password:(NSString *) password onCompletion:(void(^)(NSError * error))completionHandler;

/* Provides list of all envelopes from a given folder for the logged in User */
-(void)getEnvelopesFromFolder:(DSFolderType)folderType onCompletion:(void(^)(NSArray * array, NSError * error))completionHandler;

/* Provides list of all templates for the logged in User */
-(void)getAllTemplatesOnCompletion:(void(^)(NSArray * array, NSError * error))completionHandler;

/* Provides list of all envelopes and their statuses for the logged in User */
-(void)getAllEnvelopesOnCompletion:(void(^)(NSArray * envelopesArray, NSError * error))completionHandler;

/* Provides recipient view url for the supplied envelopeId for the logged in User */
-(void)getRecipientViewURLForEnvelopeId:(NSString *)envelopeId onCompletion:(void(^)(NSString * recipientViewURL, NSError * error))completionHandler;

/* Sends signing request to the recipient with supplied document and email subject & message  */
-(void)sendRequestForSigningDocument:(NSString *)documentName documentPath:(NSString *)documentPath recipient:(NSString *)name email:(NSString *)email subject:(NSString *)subject emailBody:(NSString *)emailbody onCompletion:(void(^)(NSError * error))completionHandler;

/* Sends signing request to the recipient with supplied template and email subject & message  */
-(void)sendRequestForSigningTemplateId:(NSString *)templateId recipient:(NSString *)name email:(NSString *)email subject:(NSString *)subject emailBody:(NSString *)emailbody onCompletion:(void(^)(NSError * error))completionHandler;

/* Downloads all the documents from the supplied envelopeId */
-(void)downloadAllDocumentsForEnvelopeId:(NSString *)envelopeId onCompletion:(void(^)(NSArray * downloadedDocuments, NSError * error))completionHandler;

@end
