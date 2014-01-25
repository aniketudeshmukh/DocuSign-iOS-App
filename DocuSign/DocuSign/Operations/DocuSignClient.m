//
//  DocuSignClient.m
//  DocuSign
//
//  Created by Aniket on 1/23/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "DocuSignClient.h"
#import "FolderItem.h"

static NSString * const kDocuSignURL = @"https://demo.docusign.net/restapi/v2/login_information";
static NSString * const kIntegratorKey = @"CAPG-db179a1d-0379-40d9-8b38-4b1717cd4553";

//Relative URLs
static NSString * const kFoldersURL = @"/folders";
static NSString * const kTemplatesURL = @"/templates";
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
                    //Remove Duplicate Records
                    NSArray * distinctObjects = [[NSOrderedSet orderedSetWithArray:jsonResponse[@"folderItems"]] array];
                    
                    //Process Valid Response
                    folderItemsArray = [NSMutableArray array];
                    for (NSDictionary * object in distinctObjects) {
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
    
    NSDictionary *embeddedRequestData = @{@"returnUrl": @"http://done",
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

-(void)sendRequestForSigningDocument:(NSString *)documentName receipient:(NSString *)name email:(NSString *)email subject:(NSString *)subject emailBody:(NSString *)emailbody onCompletion:(void(^)(NSString * receipientViewURL, NSError * error))completionHandler {
    NSString *envelopesURL = [NSMutableString stringWithFormat:@"%@/envelopes",self.currentUser.baseUrl];
    NSMutableURLRequest *signatureRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:envelopesURL]];
    [signatureRequest setHTTPMethod:@"POST"];
    [signatureRequest setURL:[NSURL URLWithString:envelopesURL]];
    // construct a JSON formatted signature request body (multi-line for readability)
    NSDictionary *signatureRequestData =
    @{@"accountId": self.currentUser.accountId,
      @"emailSubject" : @"Signature Request on Document API call",
      @"emailBlurb" : @"email body",
      @"documents" : [NSArray arrayWithObjects: @{@"documentId":@"1", @"name": documentName}, nil ],
      @"recipients" : @{ @"signers": [NSArray arrayWithObjects:
                                      @{@"email": email,
                                        @"name": name,
                                        @"recipientId": @"1",
                                        @"tabs": @{ @"signHereTabs": [NSArray arrayWithObjects:
                                                                      @{@"xPosition": @"100",
                                                                        @"yPosition": @"100",
                                                                        @"documentId": @"1",
                                                                        @"pageNumber": @"1"}, nil ]}}, nil ] },
      @"status" : @"sent"
      };
    // convert dictionary object to JSON formatted string
    NSString *sigRequestDataString = [self jsonStringFromObject:signatureRequestData];
    // read document bytes and place in the request
    NSString *appDirectory = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@", appDirectory, documentName];
    // use an NSData object to store the document bytes
    NSData *filedata = [NSData dataWithContentsOfFile:fullFilePath];
    // create the boundary separated request body...
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:
                       @"\r\n"
                       "\r\n"
                       "--AAA\r\n"
                       "Content-Type: application/json\r\n"
                       "Content-Disposition: form-data\r\n"
                       "\r\n"
                       "%@\r\n"
                       "--AAA\r\n"
                       "Content-Type: application/pdf\r\n"
                       "Content-Disposition: file; filename=\"%@\"; documentid=1; fileExtension=\"pdf\" \r\n"
                       "\r\n",
                       sigRequestDataString, documentName] dataUsingEncoding:NSUTF8StringEncoding]];
    // next append the document bytes
    [body appendData:filedata];
    // append closing boundary and CRLFs
    [body appendData:[[NSString stringWithFormat:
                       @"\r\n"
                       "--AAA--\r\n"
                       "\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    // add the body to the request
    [signatureRequest setHTTPBody:body];
    // authentication and content-type headers
    [signatureRequest setValue:self.authenticationString forHTTPHeaderField:@"X-DocuSign-Authentication"];
    [signatureRequest setValue:@"multipart/form-data; boundary=AAA" forHTTPHeaderField:@"Content-Type"];
    //*** make the signature request!
    
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:signatureRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        //--- display results
        NSLog(@"Envelope Sent! Response is: %@\n", responseDictionary);

    }];
    [task resume];
}


-(void)downloadAllDocumentsForEnvelopeId:(NSString *)envelopeId onCompletion:(void(^)(NSArray * downloadedDocuments, NSError * error))completionHandler {
    ///////////////////////////////////////////////////////////////////////////////////////
    // Get Document Info for specified envelope
    ///////////////////////////////////////////////////////////////////////////////////////

    // append /envelopes/{envelopeId}/documents URI to baseUrl and use as endpoint for next request
    NSString *documentsURL = [NSMutableString stringWithFormat:@"%@/envelopes/%@/documents", self.currentUser.baseUrl, envelopeId];

    NSMutableURLRequest *documentsRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:documentsURL]];
    [documentsRequest setHTTPMethod:@"GET"];

    [documentsRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [documentsRequest setValue:self.authenticationString forHTTPHeaderField:@"X-DocuSign-Authentication"];

    NSMutableArray * downloadedDocumentsArray = [NSMutableArray array];

    [NSURLConnection sendAsynchronousRequest:documentsRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *documentsResponse, NSData *documentsData, NSError *documentsError) {
        NSError *documentsJSONError = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:documentsData options:kNilOptions error:&documentsJSONError];
        if (documentsError){
            NSLog(@"Error sending request: %@. Got response: %@", documentsRequest, documentsResponse);
            NSLog( @"Response = %@", documentsResponse );
            return;
        }
        NSLog( @"Documents info for envelope is:\n%@", jsonResponse);
        NSError *jsonError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:documentsData options:kNilOptions error:&jsonError];
        // grab documents info for the next step...
        NSArray *documentsArray = responseDictionary[@"envelopeDocuments"];

        ///////////////////////////////////////////////////////////////////////////////////////
        // STEP 3 - Download each envelope document
        ///////////////////////////////////////////////////////////////////////////////////////

        NSMutableString *docUri;
        NSMutableString *docName;
        NSMutableString *docURL;

        // loop through each document uri and download each doc (including the envelope's certificate)
        for (int i = 0; i < [documentsArray count]; i++)
        {
            docUri = [documentsArray[i] objectForKey:@"uri"];
            docName = [documentsArray[i] objectForKey:@"name"];
            docURL = [NSMutableString stringWithFormat: @"%@/%@", self.currentUser.baseUrl, docUri];

            [documentsRequest setHTTPMethod:@"GET"];
            [documentsRequest setURL:[NSURL URLWithString:docURL]];
            [documentsRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [documentsRequest setValue:self.authenticationString forHTTPHeaderField:@"X-DocuSign-Authentication"];

            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *responseCode = nil;
            NSData *oResponseData = [NSURLConnection sendSynchronousRequest:documentsRequest returningResponse:&responseCode error:&error];
            NSMutableString *jsonResponse = [[NSMutableString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
            if([responseCode statusCode] != 200){
                NSLog(@"Error sending %@ request to %@\nHTTP status code = %i", [documentsRequest HTTPMethod], docURL, [responseCode statusCode]);
                NSLog( @"Response = %@", jsonResponse );
                return;
            }

            // download the document to the documents directory of this app
            NSFileManager * fileManager = [NSFileManager defaultManager];
            NSString * documentsDirectory = [(NSURL *)[[fileManager URLsForDirectory:NSDocumentDirectory
                                                    inDomains:NSUserDomainMask] lastObject] path];
            NSString * envelopeDirectory = [documentsDirectory stringByAppendingPathComponent:envelopeId];
            if (![fileManager fileExistsAtPath:envelopeDirectory]) {
                [fileManager createDirectoryAtPath:envelopeDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if ([docName isEqualToString:@"Summary"]) {
                docName = [@"Summary.pdf" mutableCopy];
            }
            NSString *filePath = [envelopeDirectory stringByAppendingPathComponent:docName];
            [oResponseData writeToFile:filePath atomically:YES];
            [downloadedDocumentsArray addObject:filePath];
            NSLog(@"Envelope document - %@ - has been downloaded to %@\n", docName, filePath);
        } // end for
    }];

    //Post Errors
    NSError * error = nil;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        completionHandler(downloadedDocumentsArray,error);
    }];
}

-(void)sendRequestForSigningTemplateId:(NSString *)templateId receipient:(NSString *)name email:(NSString *)email subject:(NSString *)subject emailBody:(NSString *)emailbody onCompletion:(void(^)(NSString * receipientViewURL, NSError * error))completionHandler {

    ///////////////////////////////////////////////////////////////////////////////////////
    // Request Signature via Template
    ///////////////////////////////////////////////////////////////////////////////////////

    // append "/envelopes" URI to your baseUrl and use as endpoint for signature request call
    NSString *envelopesURL = [NSMutableString stringWithFormat:@"%@/envelopes",self.currentUser.baseUrl];

    NSMutableURLRequest *signatureRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:envelopesURL]];

    [signatureRequest setHTTPMethod:@"POST"];
    [signatureRequest setURL:[NSURL URLWithString:envelopesURL]];

    // construct a JSON formatted signature request body (multi-line for readability)
    NSDictionary *signatureRequestData = @{@"accountId": self.currentUser.accountId,
                                           @"emailSubject" : @"Template API call",
                                           @"emailBlurb" : @"email body",
                                           @"templateId" : templateId,
                                           @"templateRoles" : [NSArray arrayWithObjects: @{@"email":email, @"name": name}, nil ],
                                           @"status" : @"sent"
                                           };

    // convert request body into an NSData object
    NSData* data = [[self jsonStringFromObject:signatureRequestData] dataUsingEncoding:NSUTF8StringEncoding];

    // attach body to the request
    [signatureRequest setHTTPBody:data];

    // authentication and content-type headers
    [signatureRequest setValue:self.authenticationString forHTTPHeaderField:@"X-DocuSign-Authentication"];
    [signatureRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    //*** make the signature request!
    [NSURLConnection sendAsynchronousRequest:signatureRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *envelopeResponse, NSData *envelopeData, NSError *envelopeError) {

        NSError *jsonError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:envelopeData options:kNilOptions error:&jsonError];
        NSLog(@"Envelope Sent!  Response is: %@\n", responseDictionary);
    }];
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
