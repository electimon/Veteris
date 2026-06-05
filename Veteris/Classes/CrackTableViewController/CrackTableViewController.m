//
//  CrackTableViewController.m
//  Crackulous
//
//  Created by electimon on 6/3/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "CrackTableViewController.h"
#import "../CrackTableViewCell/CrackTableViewCell.h"
#import "../NSTask.h"
#import "../../SVProgressHUD/SVProgressHUD.h"
#import "../../Clutch/ApplicationLister.h"
#import "../../Clutch/Application.h"
#import "../../Clutch/Cracker.h"

@interface CrackTableViewController ()

@end

@implementation CrackTableViewController {
    NSArray *appList;
    NSInteger selectedIndex;
    BOOL queueEmpty;
    NSOperationQueue *queue;
    NSMutableArray *selectedRows;
    NSMutableArray *crackingArray;
    NSMutableArray *doneArray;
    NSMutableArray *queueArray;
    __weak IBOutlet UIBarButtonItem *crackBtn;
    UILabel *noAppLabel;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    crackingArray = [NSMutableArray new];
    doneArray = [NSMutableArray new];
    queueArray = [NSMutableArray new];
    queueEmpty = YES;
    selectedIndex = 0;
    selectedRows = [NSMutableArray new];

    // No apps label
    noAppLabel = [[UILabel alloc] initWithFrame:self.view.frame];
    noAppLabel.text = @"No crackable apps found!";
    noAppLabel.alpha = 0.7;
    [noAppLabel sizeToFit];
    [noAppLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    noAppLabel.hidden = YES;
    [self.navigationController.view addSubview:noAppLabel];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    appList = [[ApplicationLister sharedInstance] installedApps];
    if (appList.count == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        noAppLabel.hidden = NO;
        //NSLog(self.navigationItem.leftBarButtonItem.title);
        ((UISegmentedControl*)self.navigationItem.titleView).hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appList = [[ApplicationLister sharedInstance] installedApps];
    if (appList.count == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        noAppLabel.hidden = NO;
        ((UISegmentedControl*)self.navigationItem.titleView).hidden = YES;
    } else {
        noAppLabel.hidden = YES;
        ((UISegmentedControl*)self.navigationItem.titleView).hidden = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (selectedIndex == 1) {
        tableView.allowsMultipleSelection = NO;
        return 3;
    } else {
        tableView.allowsMultipleSelection = YES;
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (selectedIndex) {
        switch (section) {
            case 0:
                return @"Done";
            case 1:
                return @"Cracking";
            case 2:
                return @"Queue";
            default:
                return @"";
        }
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (!selectedIndex) {
        return [appList count];
    } else {
        switch (section) {
            case 0:
                DEBUG(@"got done array count = %i", [doneArray count]);
                return [doneArray count];
            case 1:
                DEBUG(@"got cracking array count = %i", [crackingArray count]);
                return [crackingArray count];
            case 2:
                DEBUG(@"got queue array count = %i", [queueArray count]);
                return [queueArray count];
            default:
                return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CrackTableViewCell";
    CrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.cellIndicator.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (!selectedIndex) {
        Application *app = [appList objectAtIndex:indexPath.row];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = app.applicationDisplayName;
        cell.cellImage.image = app.applicationIcon;
        cell.cellVersionLabel.text = [NSString stringWithFormat:@"Version: %@", app.applicationVersion];
        if ([self inQueues:app]) {
            cell.contentView.backgroundColor = [UIColor grayColor];
        }
    } else {
        if ([crackingArray count] != 0 || [queueArray count] != 0 || [doneArray count] != 0) {
            Application *app;
            switch (indexPath.section) {
                case 0:
                    NSLog(@"IN DA DONE SECTION");
                    app = [doneArray objectAtIndex:indexPath.row];
                    cell.cellIndicator.hidden = YES;
                    [cell.cellIndicator stopAnimating];
                    if (app->finishedSuccessfully) {
                        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        cell.contentView.backgroundColor = [UIColor greenColor];
                    } else {
                        cell.contentView.backgroundColor = [UIColor redColor];
                    }
                    break;
                case 1:
                    NSLog(@"IN DA Cracking");
                    app = [crackingArray objectAtIndex:indexPath.row];
                    cell.cellIndicator.hidden = NO;
                    [cell.cellIndicator startAnimating];
                    break;
                case 2:
                    app = [queueArray objectAtIndex:indexPath.row];
                    NSLog(@"IN DA Queue");
                    break;
                default:
                    NSLog(@"fuck off = %i", indexPath.section);
                    return nil;
            }
            cell.cellLabel.text = app.applicationDisplayName;
            cell.cellImage.image = app.applicationIcon;
            cell.cellVersionLabel.text = [NSString stringWithFormat:@"Version: %@", app.applicationVersion];
            
        } else {
            NSLog(@"women arent trophies");
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!selectedIndex) {
        if (![self inQueues:[appList objectAtIndex:indexPath.row]]) {
            CrackTableViewCell *cell = (CrackTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            if([[tableView indexPathsForSelectedRows] containsObject:indexPath]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            [selectedRows addObject:indexPath];
            [self updateCrackButtonState];
        } else {
            NSLog(@"Operation already ran for this app!");
        }
    } else {
        Application *app = [appList objectAtIndex:indexPath.row];
        if ([doneArray containsObject:app]) {
            if (app->finishedSuccessfully) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:app.applicationDisplayName
                                  delegate:self 
                                  cancelButtonTitle:@"Cancel!"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil, nil];
                [actionSheet showInView:self.view];
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!selectedIndex) {
        if (![self inQueues:[appList objectAtIndex:indexPath.row]]) {
            NSLog(@"deselected");
            CrackTableViewCell *cell = (CrackTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self updateCrackButtonState];
            [selectedRows removeObject:indexPath];
        }
    }
}

- (IBAction)segControlValueChanged:(id)sender {
    NSLog(@"changed to %i", [(UISegmentedControl*)sender selectedSegmentIndex]);
    selectedIndex = [(UISegmentedControl*)sender selectedSegmentIndex];
    if (selectedIndex == 1) {
        NSLog(@"selected rows = %@", self.tableView.indexPathsForSelectedRows);
        selectedRows = [self.tableView.indexPathsForSelectedRows mutableCopy];
        [[self tableView] reloadData];
    } else {
        [[self tableView] reloadData];
        for (NSIndexPath *path in selectedRows) {
            Application *app = [appList objectAtIndex:path.row];
            if (![self inQueues:app]) {
                NSLog(@"set in loop");
                CrackTableViewCell *cell = (CrackTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [[self tableView] selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    [self updateCrackButtonState];
}

-(void)showUIAlertView:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)CBTitle {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:CBTitle otherButtonTitles:nil] show];
}

- (IBAction)crackButtonPressed:(id)sender {
    for (NSIndexPath *path in selectedRows) {
        CrackTableViewCell *cell = (CrackTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
        cell.contentView.backgroundColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        Application *app = [appList objectAtIndex:path.row];
        if ([crackingArray containsObject:app] || [doneArray containsObject:app] || [queueArray containsObject:app]) {
            NSLog(@" Already in the queue you donut");
            continue;
        }
        NSLog(@"app name = %@", app.applicationDisplayName);
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            [queueArray removeObject:app];
            [crackingArray addObject:app];
            #warning Remove this in production
            sleep(5);
            // DO cracking
            Cracker *cracker = [[Cracker alloc] init];
            [cracker prepareFromInstalledApp:app];
                
            NSString *ipapath = [cracker generateIPAPath];
                
            if ([cracker execute]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"done you bitch");
                    NSLog(@"DONT SWALLOW IT oh and done finished finito completed success here %@", ipapath);
                    app->finishedSuccessfully = true;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"done you bitch");
                    NSLog(@"WE FUCKING FIALED");
                });
            }
            [crackingArray removeObject:app];
            [doneArray addObject:app];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        if (![[queue operations] containsObject:op]) {
            [queueArray addObject:app];
            [queue addOperation:op];
        }
    }
    crackBtn.enabled = NO;
    NSLog(@"running operation count is %i", queue.operationCount);
}

-(void)updateCrackButtonState {
    if (self.tableView.indexPathsForSelectedRows) {
        crackBtn.enabled = YES;
    } else {
        crackBtn.enabled = NO;
    }
}

-(BOOL)inQueues:(Application*)app {
    if (![queueArray containsObject:app] && ![crackingArray containsObject:app] && ![doneArray containsObject:app]) {
        return NO;
    } else {
        return YES;
    }
}

@end
