//
//  DocuSignClient.h
//  DocuSign
//
//  Created by Aniket on 1/23/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocuSignClient : NSObject

+(instancetype)sharedInstance;
-(void)loginUser:(NSString *)user password:(NSString *) password onCompletion:(void(^)(NSError * error))completionHandler;
-(void)getDocumentsWaitingForMySignatureOnCompletion:(void(^)(NSArray * array, NSError * error))completionHandler;

@end
