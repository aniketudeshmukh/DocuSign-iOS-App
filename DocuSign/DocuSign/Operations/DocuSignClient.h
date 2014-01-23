//
//  DocuSignClient.h
//  DocuSign
//
//  Created by Aniket on 1/23/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DSFolderType) {
    AwaitingMySignature = 0,
    Drafts,
    Completed,
    OutForSignature,
};

@interface DocuSignClient : NSObject
@property (nonatomic, strong, readonly) NSString * authenticationString;
+(instancetype)sharedInstance;
-(void)loginUser:(NSString *)user password:(NSString *) password onCompletion:(void(^)(NSError * error))completionHandler;
-(void)getEnvelopesFromFolder:(DSFolderType)folderType onCompletion:(void(^)(NSArray * array, NSError * error))completionHandler;
-(void)getRecipientViewURLForEnvelopeId:(NSString *)envelopeId onCompletion:(void(^)(NSString * receipientViewURL, NSError * error))completionHandler;
@end
