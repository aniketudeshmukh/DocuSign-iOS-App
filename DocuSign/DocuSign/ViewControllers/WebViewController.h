//
//  WebViewController.h
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderItem.h"
@interface WebViewController : UIViewController
@property (strong, nonatomic) FolderItem * item;
@property (strong, nonatomic) NSURL * url;
@end
