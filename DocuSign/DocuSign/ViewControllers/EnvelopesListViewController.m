//
//  EnvelopesListViewController.m
//  DocuSign
//
//  Created by Aniket on 1/27/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "EnvelopesListViewController.h"
#import "Envelope.h"
#import "MBProgressHUD.h"
#import "DocuSignClient.h"


@interface EnvelopesListViewController ()
@property (nonatomic, strong) NSArray * envelopes;
-(void)configureView;
-(void)fetchDocuments;
@end

@implementation EnvelopesListViewController

- (void)viewDidLoad {
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
    MBProgressHUD * hud =[MBProgressHUD showHUDAddedTo:self.tableView animated:NO];
    hud.labelText = @"This may take few seconds...";
}

-(void)fetchDocuments {
    if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];

    //Get All Envelopes & their statues from DocuSign server
    DocuSignClient * client = [DocuSignClient sharedInstance];
    [client getAllEnvelopesOnCompletion:^(NSArray *envelopesArray, NSError *error) {

        //Sort Envelopes by Statuses
        NSMutableArray * sortedArray = [NSMutableArray array];
        NSArray * status = [envelopesArray valueForKeyPath:@"@distinctUnionOfObjects.status"];
        [status enumerateObjectsUsingBlock:^(NSString * currentStatus, NSUInteger idx, BOOL *stop) {
            NSArray * filteredEnvelopes = [envelopesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status = %@",currentStatus]];
            NSDictionary * dictionary = @{@"status" : currentStatus, @"envelopes" : filteredEnvelopes};
            [sortedArray addObject:dictionary];
        }];

        self.envelopes = sortedArray;

        //Hide Activity Indicator
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
        if (self.refreshControl != nil && self.refreshControl.isRefreshing == YES) {
            [self.refreshControl endRefreshing];
            if (self.refreshControl) self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
        }
        [self.tableView reloadData];
    }];
}


#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.envelopes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.envelopes[section] valueForKey:@"envelopes" ] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.envelopes[section] valueForKey:@"status"] uppercaseString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray * envelopes = (NSArray *)[self.envelopes[indexPath.section] valueForKey:@"envelopes"];
    Envelope * envelope = (Envelope *) envelopes[indexPath.row];
    cell.textLabel.text = envelope.emailSubject;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ on %@",[self.envelopes[indexPath.section] valueForKey:@"status"], envelope.statusChangedDateTime];
    
    return cell;
}

@end
