//
//  MenuViewController.m
//  DocuSign
//
//  Created by Aniket Deshmukh on 23/01/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "MenuViewController.h"
#import "DocuSignClient.h"
#import "DocumentsListViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowDocumentsList"]) {
        NSIndexPath * indexPath = (NSIndexPath *)sender;
        DSFolderType folderType;
        switch (indexPath.row) {
            case 0:
                folderType = AwaitingMySignature;
                break;
            case 1:
                folderType = Drafts;
                break;
            case 2:
                folderType = OutForSignature;
                break;
            case 3:
                folderType = Completed;
                break;
            default:
                break;
        }
        if ([segue.destinationViewController isKindOfClass:[DocumentsListViewController class]]) {
            DocumentsListViewController * destinationVC = (DocumentsListViewController *)segue.destinationViewController;
            destinationVC.folderType = folderType;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"ShowDocumentsList" sender:indexPath];
    }
}
@end
