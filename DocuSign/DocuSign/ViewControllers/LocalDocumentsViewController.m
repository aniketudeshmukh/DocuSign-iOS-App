//
//  LocalDocumentsViewController.m
//  DocuSign
//
//  Created by Aniket on 1/25/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "LocalDocumentsViewController.h"
#import "LocalDocument.h"

@interface LocalDocumentsViewController ()
@property (nonatomic,strong) NSArray * documents;
@end

@implementation LocalDocumentsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchLocalDocuments];
}

- (void)fetchLocalDocuments {
    NSMutableArray * documents = [NSMutableArray array];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * documentsDirectory = [(NSURL *)[[fileManager URLsForDirectory:NSDocumentDirectory
                                                                   inDomains:NSUserDomainMask] lastObject] path];
    NSArray * directoryContents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    [directoryContents enumerateObjectsUsingBlock:^(NSString * fileName, NSUInteger idx, BOOL *stop) {
        NSString * filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        BOOL isDirectory;
        [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (!isDirectory) {
            LocalDocument * document = [[LocalDocument alloc] init];
                    document.name = fileName;
                    document.path = filePath;
            [documents addObject:document];
        }
    }];
    self.documents = documents;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.documents.count == 0) ? 1 : self.documents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DocumentsCustomCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    if (self.documents.count == 0) {
        cell.textLabel.text = @"No Documents Available.";
    }
    else {
        LocalDocument * document = (LocalDocument *) self.documents[indexPath.row];
        cell.textLabel.text = document.name;
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.documents.count > 0) ? indexPath : nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

@end
