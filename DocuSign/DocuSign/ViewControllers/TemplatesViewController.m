//
//  TemplatesViewController.m
//  DocuSign
//
//  Created by Aniket on 1/25/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "TemplatesViewController.h"
#import "DocuSignClient.h"
#import "MBProgressHUD.h"
#import "EnvelopeTemplate.h"

@interface TemplatesViewController ()
@property (nonatomic,strong) NSArray * templates;
- (void)configureView;
- (void)fetchAllTemplates;
@end

@implementation TemplatesViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [self fetchAllTemplates];
}


#pragma mark - TemplatesViewController

- (void)configureView {
    //Add Pull To Refresh Functionality
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
    [self.refreshControl addTarget:self action:@selector(fetchAllTemplates) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
}

- (void)fetchAllTemplates {
    //Fetch all templates from the server
    if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    DocuSignClient * client = [DocuSignClient sharedInstance];
    [client getAllTemplatesOnCompletion:^(NSArray *array, NSError *error) {
        if (!error) {
            self.templates = array;
        }
        else {
            //Show Error
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        }
        //Hide Activity Indicator
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
        if (self.refreshControl != nil && self.refreshControl.isRefreshing == YES) {
            [self.refreshControl endRefreshing];
            if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
        }
        [self.tableView reloadData];
    }];
}


#pragma mark - UITableViewControllerDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.templates.count == 0) ? (self.refreshControl.isRefreshing) ? 0 : 1 : self.templates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TemplateCustomCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    if (self.templates.count == 0) {
        cell.textLabel.text = @"No Templates Available.";
    }
    else {
        EnvelopeTemplate * template = (EnvelopeTemplate *) self.templates[indexPath.row];
        cell.textLabel.text = template.name;
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.templates.count > 0) ? indexPath : nil;
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
