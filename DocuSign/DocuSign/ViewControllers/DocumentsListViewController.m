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
#import "DownloadedDocument.h"
#import "FolderItem.h"
#import "FolderItemCustomCell.h"
#import "MBProgressHUD.h"

@interface DocumentsListViewController ()
@property (nonatomic,strong) NSArray * folderItems;
@property (nonatomic,strong) NSMutableArray * downloadedDocuments;
@end

@implementation DocumentsListViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [self fetchDocuments];
}

-(void)configureView {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
    [self.refreshControl addTarget:self action:@selector(fetchDocuments) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
}

-(void)fetchDocuments {
    if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    DocuSignClient * client = [DocuSignClient sharedInstance];
    
#warning TO DO If Downlaoded

    if (self.folderType == Downloaded) {
        //TODO: FetchDocuments from Local folder.
        self.downloadedDocuments = [NSMutableArray array];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * documentsDirectory = [(NSURL *)[[fileManager URLsForDirectory:NSDocumentDirectory
                                                                      inDomains:NSUserDomainMask] lastObject] path];
        NSArray * envelopsArray = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
        [envelopsArray enumerateObjectsUsingBlock:^(NSString * directory, NSUInteger idx, BOOL *stop) {
            NSString * envelopeDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
            BOOL isDirectory;
            [fileManager fileExistsAtPath:envelopeDirectory isDirectory:&isDirectory];
            if (isDirectory) {
                NSArray * documents = [fileManager contentsOfDirectoryAtPath:envelopeDirectory error:nil];
                DownloadedDocument * document = [[DownloadedDocument alloc] init];
                [documents enumerateObjectsUsingBlock:^(NSString * documentName, NSUInteger idx, BOOL *stop) {
                    if ([documentName isEqualToString:@"Summary.pdf"]) {
                        document.summaryPath = [envelopeDirectory stringByAppendingPathComponent:documentName];
                    }
                    else {
                        document.documentName = documentName;
                        document.documentPath = [envelopeDirectory stringByAppendingPathComponent:documentName];
                    }
                }];
                [self.downloadedDocuments addObject:document];
            }
        }];
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
        if (self.refreshControl != nil && self.refreshControl.isRefreshing == YES) {
            [self.refreshControl endRefreshing];
            if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
        }
        [self.tableView reloadData];
    } else {
        [client getEnvelopesFromFolder:self.folderType onCompletion:^(NSArray *array, NSError *error) {
            self.folderItems = array;
            [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
            if (self.refreshControl != nil && self.refreshControl.isRefreshing == YES) {
                [self.refreshControl endRefreshing];
                if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
            }
            [self.tableView reloadData];
        }];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.folderType == Downloaded) {
        return (self.downloadedDocuments.count == 0) ? (self.refreshControl.isRefreshing) ? 0 : 1 : self.downloadedDocuments.count;
    }
    else {
        return (self.folderItems.count == 0) ? (self.refreshControl.isRefreshing) ? 0 : 1 : self.folderItems.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
    NSString * cellIdentifier = @"Cell";

    if (self.folderType == Downloaded) {
        if (self.downloadedDocuments.count == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"No Documents Available.";
        } else {
            cellIdentifier = @"DownloadedDocumentsCustomCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            FolderItemCustomCell * itemCell = (FolderItemCustomCell *)cell;
            itemCell.titleLabel.text = ((DownloadedDocument *)self.downloadedDocuments[indexPath.row]).documentName;
        }
    }
    else {
        if (self.folderItems.count == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"No Documents Available.";
        }
        else {
            if (self.folderType == Completed) {
                cellIdentifier = @"CompletedCustomCell";
            }
            else {
                cellIdentifier = @"FolderItemCustomCell";
            }
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

            if (self.folderType == Completed) {
                UIButton * downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 19, 57)];
                UIImage * downloadImage = [[UIImage imageNamed:@"Download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [downloadButton setImage:downloadImage forState:UIControlStateNormal];
                [downloadButton addTarget:self action:@selector(downloadButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = downloadButton;
            }
            FolderItemCustomCell * itemCell = (FolderItemCustomCell *)cell;
            FolderItem * item = (FolderItem *)self.folderItems[indexPath.row];
            itemCell.titleLabel.text = item.subject;
            itemCell.senderLabel.text = item.senderName;
            itemCell.sentLabel.text = item.sentDateTime;
        }
    }
    return cell;
}


-(void)downloadButtonTapped:(UIControl *)button withEvent:(UIEvent *)event {
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil ) return;
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    [button addSubview:activityIndicator];
//    button.hidden = YES;
    DocuSignClient * client = [DocuSignClient sharedInstance];
    FolderItem * item = (FolderItem *)self.folderItems[indexPath.row];
    [client downloadAllDocumentsForEnvelopeId:item.envelopeId onCompletion:^(NSArray *downloadedDocuments, NSError *error) {
        [activityIndicator stopAnimating];
        if (!error) {

        }
        else {
//            button.hidden = NO;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Download Failed" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
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
    else if ([segue.identifier isEqualToString:@"ShowDocuSignWebView"] || [segue.identifier isEqualToString:@"ShowDocuSignWebViewForCompletedDocument"]) {
        if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
            WebViewController * destinationVC = (WebViewController *)segue.destinationViewController;
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                NSInteger row = [self.tableView indexPathForCell:sender].row;
                destinationVC.item = self.folderItems[row];
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowDownloadedDocument"]) {
        if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
            WebViewController * destinationVC = (WebViewController *)segue.destinationViewController;
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                NSInteger row = [self.tableView indexPathForCell:sender].row;
                destinationVC.url = [NSURL fileURLWithPath:((DownloadedDocument *)self.downloadedDocuments[row]).documentPath];
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowDownloadedDocumentSummary"]) {
        if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
            WebViewController * destinationVC = (WebViewController *)segue.destinationViewController;
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                NSInteger row = [self.tableView indexPathForCell:sender].row;
                destinationVC.url = [NSURL fileURLWithPath:((DownloadedDocument *)self.downloadedDocuments[row]).summaryPath];
            }
        }
    }
}

@end
