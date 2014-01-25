//
//  DownloadedDocument.h
//  DocuSign
//
//  Created by Aniket on 1/25/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadedDocument : NSObject
@property (nonatomic, strong) NSString * documentName;
@property (nonatomic, strong) NSString * documentPath;
@property (nonatomic, strong) NSString * summaryPath;
@end
