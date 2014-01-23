//
//  FolderItemCustomCell.h
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderItemCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentLabel;
@end
