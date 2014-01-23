//
//  User.m
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "User.h"

@implementation User

-(void)setAttributes:(NSDictionary *)attributes {
    self.accountId = attributes[@"accountId"];
    self.baseUrl = attributes[@"baseUrl"];
    self.email = attributes[@"email"];
    self.userId = attributes[@"userId"];
    self.userName = attributes[@"userName"];
}

@end
