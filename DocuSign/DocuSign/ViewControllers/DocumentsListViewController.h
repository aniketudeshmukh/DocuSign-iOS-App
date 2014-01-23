//
//  DocumentsListViewController.h
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocuSignClient.h"

@interface DocumentsListViewController : UITableViewController
@property (nonatomic,assign) DSFolderType folderType;
@end
