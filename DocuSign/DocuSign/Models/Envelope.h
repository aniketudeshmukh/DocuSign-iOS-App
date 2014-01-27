//
//  Envelope.h
//  DocuSign
//
//  Created by Aniket on 1/27/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Envelope : NSObject
@property (nonatomic, copy) NSString * certificateUri;
@property (nonatomic, copy) NSString * customFieldsUri;
@property (nonatomic, copy) NSString * documentsCombinedUri;
@property (nonatomic, copy) NSString * documentsUri;
@property (nonatomic, copy) NSString * emailSubject;
@property (nonatomic, copy) NSString * envelopeId;
@property (nonatomic, copy) NSString * envelopeUri;
@property (nonatomic, copy) NSString * notificationUri;
@property (nonatomic, copy) NSString * recipientsUri;
@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) NSString * statusChangedDateTime;
@property (nonatomic, copy) NSString * createdDateTime;
@property (nonatomic, copy) NSString * deliveredDateTime;
@property (nonatomic, copy) NSString * sentDateTime;
@property (nonatomic, copy) NSString * completedDateTime;
-(void)setAttributes:(NSDictionary *)attributes;
@end
