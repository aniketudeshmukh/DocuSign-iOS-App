//
//  DownloadedDocumentsViewController.m
//  DocuSign
//
//  Created by Aniket on 1/26/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "DownloadedDocumentsViewController.h"
#import "MBProgressHUD.h"
#import "DownloadedDocument.h"
#import "WebViewController.h"

@interface DownloadedDocumentsViewController ()
@property (nonatomic,strong) NSMutableArray * downloadedDocuments;
@end

@implementation DownloadedDocumentsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self fetchDocuments];
}

-(void)fetchDocuments {
    //FetchDocuments from Local folder.
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
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
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.downloadedDocuments.count == 0) ? 1 : self.downloadedDocuments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (self.downloadedDocuments.count == 0) {
        cell.textLabel.text = @"No Documents Available.";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.textLabel.text = ((DownloadedDocument *)self.downloadedDocuments[indexPath.row]).documentName;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return cell;
}

#pragma mark Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowDownloadedDocument"]) {
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
