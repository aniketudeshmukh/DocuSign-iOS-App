//
//  User.h
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic,copy) NSNumber * accountId;
@property (nonatomic,copy) NSString * baseUrl;
@property (nonatomic,copy) NSString * email;
@property (nonatomic,copy) NSString * userId;
@property (nonatomic,copy) NSString * userName;
-(void)setAttributes:(NSDictionary *)attributes;
@end
