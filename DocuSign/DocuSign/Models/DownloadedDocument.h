//
//  DownloadedDocument.h
//  DocuSign
//
//  Created by Aniket on 1/25/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadedDocument : NSObject
@property (nonatomic, copy) NSString * documentName;
@property (nonatomic, copy) NSString * documentPath;
@property (nonatomic, copy) NSString * summaryPath;
@end
