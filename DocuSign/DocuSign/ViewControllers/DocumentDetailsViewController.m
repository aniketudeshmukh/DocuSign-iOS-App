//
//  DocumentDetailsViewController.m
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "DocumentDetailsViewController.h"

@interface DocumentDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiresLabel;

@end

@implementation DocumentDetailsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.item.subject;
    self.statusLabel.text = self.item.status;
    self.senderLabel.text = self.item.senderName;
    self.sentLabel.text = self.item.sentDateTime;
    self.ownerLabel.text = self.item.ownerName;
    self.createdLabel.text = self.item.createdDateTime;
    self.expiresLabel.text = self.item.expireDateTime;
}

@end
