//
//  WebViewController.h
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface WebViewController : UIViewController

//Specify the envelope id which should be displayed on DocuSign Console */
@property (nonatomic, copy) NSString * envelopeId;

@end
