//
//  DocuSignClient.m
//  DocuSign
//
//  Created by Aniket on 1/23/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "DocuSignClient.h"
#import "User.h"
#import "FolderItem.h"

static NSString * const kDocuSignURL = @"https://demo.docusign.net/restapi/v2/login_information";
static NSString * const kIntegratorKey = @"CAPG-db179a1d-0379-40d9-8b38-4b1717cd4553";

//Relative URLs
static NSString * const kFoldersURL = @"/folders";
static NSString * const kEnvelopesAwaitingMySignatureURL = @"/search_folders/awaiting_my_signature";
static NSString * const kEnvelopesDraftsURL = @"/search_folders/drafts";
static NSString * const kEnvelopesCompletedURL = @"/search_folders/completed";
static NSString * const kEnvelopesOutForSignatureURL = @"/search_folders/out_for_signature";

@interface DocuSignClient()
@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSString * authenticationString;
@property (nonatomic, strong) User * currentUser;
@end

@implementation DocuSignClient

+ (id)sharedInstance {
    static DocuSignClient * sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DocuSignClient alloc] init];
    });
    return sharedInstance;
}

//Lazy instanciation
-(NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _session;
}

-(void)loginUser:(NSString *)user password:(NSString *) password onCompletion:(void(^)(NSError * error))completionHandler {
    //Create Authentication Request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kDocuSignURL]];
    self.authenticationString = [NSString stringWithFormat:@"{\"Username\": \"%@\",\"Password\": \"%@\",\"IntegratorKey\": \"%@\"}",user,password,kIntegratorKey];
    [request setAllHTTPHeaderFields:@{@"X-DocuSign-Authentication" : self.authenticationString, @"Content-Type" : @"application/json", @"Accept" : @"application/json"}];

    NSURLSessionTask * task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         //Check for errors
         if (!error) {
             NSHTTPURLResponse * urlResponse = (NSHTTPURLResponse *) response;
             if (urlResponse.statusCode == 200 || urlResponse.statusCode == 201)  {
                 //Parse Response
                 NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                 NSLog(@"Response: %@", jsonResponse);

                 NSString * errorCode = jsonResponse[@"errorCode"];
                 if (!errorCode) {
                     //Process Valid Response
                     self.currentUser = [[User alloc] init];
                     [self.currentUser setAttributes:[jsonResponse[@"loginAccounts"] firstObject]];
                 }
                 else {
                     NSString * message = jsonResponse[@"message"];
                     error = [NSError errorWithDomain:errorCode code:-1 userInfo:@{NSLocalizedDescriptionKey : message}];
                 }
             }
             else {
                 error = [NSError errorWithDomain:@"Network Error" code:urlResponse.statusCode userInfo:@{NSLocalizedDescriptionKey : [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]}];
             }
         }

         [[NSOperationQueue mainQueue] addOperationWithBlock:^{ completionHandler(error); }];
     }];
    [task resume];
}

-(void)getEnvelopesFromFolder:(DSFolderType)folderType onCompletion:(void(^)(NSArray * array, NSError * error))completionHandler {
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self urlStringForFolder:folderType]]];
    [request setAllHTTPHeaderFields:@{@"X-DocuSign-Authentication" : self.authenticationString, @"Content-Type" : @"application/json", @"Accept" : @"application/json"}];
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableArray * folderItemsArray = nil;
        //Check for errors
        if (!error) {
            NSHTTPURLResponse * urlResponse = (NSHTTPURLResponse *) response;
            if (urlResponse.statusCode == 200 || urlResponse.statusCode == 201) {
                //Parse Response
                NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"Response: %@", jsonResponse);
                
                NSString * errorCode = jsonResponse[@"errorCode"];
                if (!errorCode) {
                    //Process Valid Response
                    folderItemsArray = [NSMutableArray array];
                    for (NSDictionary * object in jsonResponse[@"folderItems"]) {
                        FolderItem * item = [[FolderItem alloc] init];
                        [item setAttributes:object];
                        [folderItemsArray addObject:item];
                    }
                }
                else {
                    NSString * message = jsonResponse[@"message"];
                    error = [NSError errorWithDomain:errorCode code:-1 userInfo:@{NSLocalizedDescriptionKey : message}];
                }
            }
            else {
                error = [NSError errorWithDomain:@"Network Error" code:urlResponse.statusCode userInfo:@{NSLocalizedDescriptionKey : [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]}];
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ completionHandler(folderItemsArray,error); }];
    }];
    [task resume];
}

-(void)getRecipientViewURLForEnvelopeId:(NSString *)envelopeId onCompletion:(void(^)(NSString * receipientViewURL, NSError * error))completionHandler {
    NSString * embeddedURL = [NSString stringWithFormat:@"%@/envelopes/%@/views/recipient", self.currentUser.baseUrl, envelopeId];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:embeddedURL]];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:@{@"X-DocuSign-Authentication" : self.authenticationString, @"Content-Type" : @"application/json", @"Accept" : @"application/json"}];
    
    NSDictionary *embeddedRequestData = @{@"returnUrl": @"http://www.docusign.com/devcenter",
                                          @"authenticationMethod" : @"none",
                                          @"email" : self.currentUser.email,
                                          @"userName" : self.currentUser.userName,
                                          };
    NSData* data = [[self jsonStringFromObject:embeddedRequestData] dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString * receipientViewURL = nil;
        if (!error) {
            NSHTTPURLResponse * urlResponse = (NSHTTPURLResponse *) response;
            if (urlResponse.statusCode == 200 || urlResponse.statusCode == 201) {
                //Parse Response
                NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"Response: %@", jsonResponse);
                
                NSString * errorCode = jsonResponse[@"errorCode"];
                if (!errorCode) {
                    //Process Valid Response
                    receipientViewURL = jsonResponse[@"url"];
                }
                else {
                    NSString * message = jsonResponse[@"message"];
                    error = [NSError errorWithDomain:errorCode code:-1 userInfo:@{NSLocalizedDescriptionKey : message}];
                }
            }
            else {
                error = [NSError errorWithDomain:@"Network Error" code:urlResponse.statusCode userInfo:@{NSLocalizedDescriptionKey : [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]}];
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ completionHandler(receipientViewURL,error); }];
    }];
    [task resume];
}

-(NSString *)urlStringForFolder:(DSFolderType)folderType {
    NSString * urlSuffix = nil;
    switch (folderType) {
        case AwaitingMySignature:
            urlSuffix = kEnvelopesAwaitingMySignatureURL;
            break;
        case Drafts:
            urlSuffix = kEnvelopesDraftsURL;
            break;
        case Completed:
            urlSuffix = kEnvelopesCompletedURL;
            break;
        case OutForSignature:
            urlSuffix = kEnvelopesOutForSignatureURL;
            break;
        default:
            break;
    }
    return [self.currentUser.baseUrl stringByAppendingString:urlSuffix];
}

- (NSString *)jsonStringFromObject:(id)object {
    NSString *string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:object options:0 error:nil] encoding:NSUTF8StringEncoding];
    return string;
}
@end
