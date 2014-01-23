//
//  DocuSignClient.m
//  DocuSign
//
//  Created by Aniket on 1/23/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "DocuSignClient.h"

static const NSString * DocuSignURL = @"https://demo.docusign.net/restapi/v2/login_information";
static const NSString * IntegratorKey = @"CAPG-db179a1d-0379-40d9-8b38-4b1717cd4553";

@implementation DocuSignClient

+ (id)sharedInstance
{
    static DocuSignClient * sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DocuSignClient alloc] init];
    });
    return sharedInstance;
}

-(void)loginUser:(NSString *)user password:(NSString *) password onCompletion:(void(^)(NSError * error))completionHandler
{
    //Create Authentication Request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:DocuSignURL]];
    NSString * authenticationString = [NSString stringWithFormat:@"{\"Username\": \"%@\",\"Password\": \"%@\",\"IntegratorKey\": \"%@\"}",user,password,IntegratorKey];

    //Add Request Headers
    [request addValue:authenticationString forHTTPHeaderField:@"X-DocuSign-Authentication"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionTask * task = [session dataTaskWithRequest:request
                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         //Check for errors
         if (error){
            NSLog(@"Error: %@",error);
         }
         else {
             NSHTTPURLResponse * urlResponse = (NSHTTPURLResponse *) response;
             if (urlResponse.statusCode != 200) {
                 error = [NSError errorWithDomain:@"Network Error" code:urlResponse.statusCode userInfo:@{NSLocalizedDescriptionKey : [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]}];
             }
             else {
                 //Parse Response
                 NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                 NSLog(@"Response: %@", jsonResponse);

                 //Check for errors
                 NSString * errorCode = jsonResponse[@"errorCode"];
                 if (errorCode) {
                     NSString * message = jsonResponse[@"message"];
                     error = [NSError errorWithDomain:errorCode code:-1 userInfo:@{NSLocalizedDescriptionKey : message}];
                 }
             }
         }

         [[NSOperationQueue mainQueue] addOperationWithBlock:^{ completionHandler(error); }];
     }];
    [task resume];
}

-(void)getDocumentsWaitingForMySignatureOnCompletion:(void(^)(NSArray * array, NSError * error))completionHandler
{

}

@end
