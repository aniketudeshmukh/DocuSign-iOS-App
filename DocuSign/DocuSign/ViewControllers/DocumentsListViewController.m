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
-(void)configureView;
-(void)fetchDocuments;
-(void)downloadButtonTapped:(UIControl *)button withEvent:(UIEvent *)event;
@end

@implementation DocumentsListViewController

#pragma mark - UIViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [self fetchDocuments];
}


#pragma mark - DocumentsListViewController

-(void)configureView {
    //Add Pull To Refresh Functionality
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
    [self.refreshControl addTarget:self action:@selector(fetchDocuments) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
}

-(void)fetchDocuments {
    if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    //Fetch documents from DocuSign client
    DocuSignClient * client = [DocuSignClient sharedInstance];
    [client getEnvelopesFromFolder:self.folderType onCompletion:^(NSArray *array, NSError *error) {
        //Sort array by dates
        self.folderItems = [array sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sentDateTime" ascending:NO] ]];
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
        if (self.refreshControl != nil && self.refreshControl.isRefreshing == YES) {
            [self.refreshControl endRefreshing];
            if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
        }
        [self.tableView reloadData];
    }];
}

-(void)downloadButtonTapped:(UIControl *)button withEvent:(UIEvent *)event {
    //Find the cell that was tapped
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil ) return;
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];

    //Add activity indicator to the tapped cell
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    cell.accessoryView = activityIndicator;

    //Download documents from DocuSign Server
    DocuSignClient * client = [DocuSignClient sharedInstance];
    FolderItem * item = (FolderItem *)self.folderItems[indexPath.row];
    [client downloadAllDocumentsForEnvelopeId:item.envelopeId onCompletion:^(NSArray *downloadedDocuments, NSError *error) {
        [activityIndicator stopAnimating];
        if (error) {
            cell.accessoryView = button;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Download Failed" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
}


#pragma mark - UITableViewControllerDatasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.folderItems.count == 0) ? (self.refreshControl.isRefreshing) ? 0 : 1 : self.folderItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
    NSString * cellIdentifier = @"Cell";

    //Configure Cell
    if (self.folderItems.count == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"No Documents Available.";
    }
    else {
        switch (self.folderType) {
            case AwaitingMySignature:
            {
                cellIdentifier = @"WaitingForMySignatureCustomCell";
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                FolderItemCustomCell * itemCell = (FolderItemCustomCell *)cell;
                FolderItem * item = (FolderItem *)self.folderItems[indexPath.row];
                itemCell.titleLabel.text = item.subject;
                itemCell.senderLabel.text = item.senderName;
                itemCell.sentLabel.text = item.sentDateTime;
            }
                break;

            case Completed:
            {
                cellIdentifier = @"CompletedCustomCell";
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                FolderItemCustomCell * itemCell = (FolderItemCustomCell *)cell;
                FolderItem * item = (FolderItem *)self.folderItems[indexPath.row];
                itemCell.titleLabel.text = item.subject;
                itemCell.senderLabel.text = item.senderName;
                itemCell.sentLabel.text = item.sentDateTime;

                UIButton * downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 19, 57)];
                UIImage * downloadImage = [[UIImage imageNamed:@"Download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [downloadButton setImage:downloadImage forState:UIControlStateNormal];
                [downloadButton addTarget:self action:@selector(downloadButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = downloadButton;
            }
                break;

            case OutForSignature:
            {
                cellIdentifier = @"OutForSignatureCustomCell";
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                FolderItemCustomCell * itemCell = (FolderItemCustomCell *)cell;
                FolderItem * item = (FolderItem *)self.folderItems[indexPath.row];
                itemCell.titleLabel.text = item.subject;
                itemCell.senderLabel.text = item.senderName;
                itemCell.sentLabel.text = item.sentDateTime;
            }
                break;

            case Drafts:
            {
                cellIdentifier = @"DraftCustomCell";
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                FolderItemCustomCell * itemCell = (FolderItemCustomCell *)cell;
                FolderItem * item = (FolderItem *)self.folderItems[indexPath.row];
                itemCell.titleLabel.text = item.subject;
                itemCell.senderLabel.text = item.senderName;
                itemCell.sentLabel.text = item.sentDateTime;
            }
                break;
            default:
                break;
        }
    }
    return cell;
}


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowDocumentDetails"] || [segue.identifier isEqualToString:@"ShowSentDocumentDetail"]) {
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
                destinationVC.envelopeId = [(FolderItem *)self.folderItems[row] envelopeId];
            }
        }
    }
}

@end
