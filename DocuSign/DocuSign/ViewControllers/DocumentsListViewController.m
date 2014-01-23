//
//  DocumentsListViewController.m
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "DocumentsListViewController.h"
#import "DocumentDetailsViewController.h"
#import "WebViewController.h"
#import "FolderItem.h"
#import "FolderItemCustomCell.h"

@interface DocumentsListViewController ()
@property (nonatomic,strong) NSArray * folderItems;
@end

@implementation DocumentsListViewController

-(void)viewDidLoad {
    [super viewDidLoad];
//    self.refreshControl = [UIRefreshControl new];
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
//    [self.refreshControl addTarget:self action:@selector(fetchDocuments) forControlEvents:UIControlEventValueChanged];
    [self fetchDocuments];
}

-(void)fetchDocuments {
    if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    DocuSignClient * client = [DocuSignClient sharedInstance];
    [client getEnvelopesFromFolder:self.folderType onCompletion:^(NSArray *array, NSError *error) {
        self.folderItems = array;
        [self.tableView reloadData];
//        if (self.refreshControl != nil && self.refreshControl.isRefreshing == YES) {
//            [self.refreshControl endRefreshing];
//        }
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.folderItems.count == 0) ? 1 :self.folderItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
    if (self.folderItems.count == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = @"No Documents Available.";
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FolderItemCustomCell" forIndexPath:indexPath];
        FolderItemCustomCell * itemCell = (FolderItemCustomCell *)cell;
        FolderItem * item = (FolderItem *)self.folderItems[indexPath.row];
        itemCell.titleLabel.text = item.subject;
        itemCell.senderLabel.text = item.senderName;
        itemCell.sentLabel.text = item.sentDateTime;
    }
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowDocumentDetails"]) {
        if ([segue.destinationViewController isKindOfClass:[DocumentDetailsViewController class]]) {
            DocumentDetailsViewController * destinationVC = (DocumentDetailsViewController *)segue.destinationViewController;
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                NSInteger row = [self.tableView indexPathForCell:sender].row;
                destinationVC.item = self.folderItems[row];
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowDocuSignWebView"]) {
        if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
            WebViewController * destinationVC = (WebViewController *)segue.destinationViewController;
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                NSInteger row = [self.tableView indexPathForCell:sender].row;
                destinationVC.item = self.folderItems[row];
            }
        }
    }
}

@end
