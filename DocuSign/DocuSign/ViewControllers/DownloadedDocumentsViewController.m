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

@interface DownloadedDocumentsViewController ()<UIDocumentInteractionControllerDelegate>
@property (nonatomic,strong) NSMutableArray * downloadedDocuments;
-(void)fetchDocuments;
-(void)openDocument:(NSURL *)documentURL;
@end

@implementation DownloadedDocumentsViewController

#pragma mark - UIViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self fetchDocuments];
}


#pragma mark - DownloadedDocumentsViewController

-(void)fetchDocuments {
    //Fetch Documents from local folder.
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.downloadedDocuments = [NSMutableArray array];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * documentsDirectory = [(NSURL *)[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
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
}

-(void)openDocument:(NSURL *)documentURL {
    //Open selected document using UIDocumentInteractionController
    UIDocumentInteractionController * previewController = [UIDocumentInteractionController interactionControllerWithURL:documentURL];
    previewController.delegate = self;
    [previewController presentPreviewAnimated:YES];
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.downloadedDocuments.count == 0) ? 1 : self.downloadedDocuments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Configure Cell
    NSString * cellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (self.downloadedDocuments.count == 0) {
        cell.textLabel.text = @"No Documents Available.";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.textLabel.text = ((DownloadedDocument *)self.downloadedDocuments[indexPath.row]).documentName;
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openDocument:[NSURL fileURLWithPath:((DownloadedDocument *)self.downloadedDocuments[indexPath.row]).documentPath]];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self openDocument:[NSURL fileURLWithPath:((DownloadedDocument *)self.downloadedDocuments[indexPath.row]).summaryPath]];
}


#pragma mark - UIDocumentInteractionControllerDelegate
-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

@end
