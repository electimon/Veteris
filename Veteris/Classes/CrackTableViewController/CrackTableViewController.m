//
//  CrackTableViewController.m
//  Crackulous
//
//  Created by electimon on 6/3/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "CrackTableViewController.h"
#import "../../Clutch/Application.h"
#import "../../Clutch/ApplicationLister.h"
#import "../../Clutch/Cracker.h"
#import "../../SVProgressHUD/SVProgressHUD.h"
#import "../CrackTableViewCell/CrackTableViewCell.h"
#import "../../Clutch/NSTask.h"
#import "../VAPIHelper/VAPIHelper.h"

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
    __unsafe_unretained IBOutlet UIBarButtonItem *crackBtn;
    UILabel *noAppLabel;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
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
    CGRect frame = CGRectMake(self.navigationController.view.bounds.origin.x, self.navigationController.view.bounds.origin.y, self.navigationController.view.bounds.size.width, self.navigationController.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height*2);
    noAppLabel = [[UILabel alloc] initWithFrame:frame];
    noAppLabel.text = NSLocalizedString(@"NoCrackableApps", nil);
    noAppLabel.alpha = 0.7;
    noAppLabel.lineBreakMode = NSLineBreakByWordWrapping;
    noAppLabel.numberOfLines = 2;
    [noAppLabel sizeToFit];
    [noAppLabel setCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
    noAppLabel.textAlignment = NSTextAlignmentCenter;
    noAppLabel.hidden = YES;
    crackBtn.title = NSLocalizedString(@"CrackBtn", nil);
    [self.view addSubview:noAppLabel];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    appList = [[ApplicationLister sharedInstance] crackableApps];
    if (appList.count == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        noAppLabel.hidden = NO;
        // NSLog(self.navigationItem.leftBarButtonItem.title);
        ((UISegmentedControl *)self.navigationItem.titleView).hidden = YES;
    }
    [((UISegmentedControl *)self.navigationItem.titleView) setTitle:NSLocalizedString(@"Apps", nil) forSegmentAtIndex:0];
    [((UISegmentedControl *)self.navigationItem.titleView) setTitle:NSLocalizedString(@"Queue", nil) forSegmentAtIndex:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appList = [[ApplicationLister sharedInstance] crackableApps];
    if (appList.count == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        noAppLabel.hidden = NO;
        ((UISegmentedControl *)self.navigationItem.titleView).hidden = YES;
    } else {
        noAppLabel.hidden = YES;
        ((UISegmentedControl *)self.navigationItem.titleView).hidden = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView reloadData];
    }
}

- (void)viewWillUnload {
    [super viewWillUnload];
    [noAppLabel removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
                return NSLocalizedString(@"Done", @"Done");
            case 1:
                return NSLocalizedString(@"AppCracking", @"Cracking");
            case 2:
                return NSLocalizedString(@"Crack-Queue", @"Queue");
            default:
                return @"";
        }
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (!selectedIndex) {
        return [appList count];
    } else {
        switch (section) {
            case 0:
                return [doneArray count];
            case 1:
                return [crackingArray count];
            case 2:
                return [queueArray count];
            default:
                return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CrackTableViewCell";
    CrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.cellIndicator.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (!selectedIndex) {
        ApplicationC *app = [appList objectAtIndex:indexPath.row];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = app.applicationDisplayName;
        cell.cellImage.image = app.applicationIcon;
        cell.cellVersionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"version", nil), app.applicationVersion];
        if ([self inQueues:app]) {
            cell.contentView.backgroundColor = [UIColor grayColor];
        }
    } else {
        if ([crackingArray count] != 0 || [queueArray count] != 0 || [doneArray count] != 0) {
            ApplicationC *app;
            switch (indexPath.section) {
                case 0:
                    NSLog(@"IN DA DONE SECTION");
                    app = [doneArray objectAtIndex:indexPath.row];
                    cell.cellIndicator.hidden = YES;
                    [cell.cellIndicator stopAnimating];
                    if (app->finishedSuccessfully) {
                        // cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
                    NSLog(@"fuck off = %ld", (long)indexPath.section);
                    return nil;
            }
            cell.cellLabel.text = app.applicationDisplayName;
            cell.cellImage.image = app.applicationIcon;
            cell.cellVersionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"version", nil), app.applicationVersion];

        } else {
            NSLog(@"women arent trophies");
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!selectedIndex) {
        if (![self inQueues:[appList objectAtIndex:indexPath.row]]) {
            CrackTableViewCell *cell = (CrackTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            if ([[tableView indexPathsForSelectedRows] containsObject:indexPath]) {
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
        ApplicationC *app = [appList objectAtIndex:indexPath.row];
        if ([doneArray containsObject:app]) {
            if (app->finishedSuccessfully) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:app.applicationDisplayName delegate:self cancelButtonTitle:@"Cancel!" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
                [actionSheet showInView:self.view];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!selectedIndex) {
        if (![self inQueues:[appList objectAtIndex:indexPath.row]]) {
            NSLog(@"deselected");
            CrackTableViewCell *cell = (CrackTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self updateCrackButtonState];
            [selectedRows removeObject:indexPath];
        }
    }
}

- (IBAction)segControlValueChanged:(id)sender {
    NSLog(@"changed to %ld", (long)[(UISegmentedControl *)sender selectedSegmentIndex]);
    selectedIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    if (selectedIndex == 1) {
        NSLog(@"selected rows = %@", self.tableView.indexPathsForSelectedRows);
        selectedRows = [self.tableView.indexPathsForSelectedRows mutableCopy];
        [[self tableView] reloadData];
    } else {
        [[self tableView] reloadData];
        for (NSIndexPath *path in selectedRows) {
            ApplicationC *app = [appList objectAtIndex:path.row];
            if (![self inQueues:app]) {
                NSLog(@"set in loop");
                CrackTableViewCell *cell = (CrackTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [[self tableView] selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    [self updateCrackButtonState];
}

- (IBAction)crackButtonPressed:(id)sender {
    for (NSIndexPath *path in selectedRows) {
        CrackTableViewCell *cell = (CrackTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
        cell.contentView.backgroundColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        ApplicationC *app = [appList objectAtIndex:path.row];
        if ([crackingArray containsObject:app] || [doneArray containsObject:app] || [queueArray containsObject:app]) {
            NSLog(@" Already in the queue you donut");
            continue;
        }
        NSLog(@"app name = %@", app.applicationDisplayName);
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            [queueArray removeObject:app];
            [crackingArray addObject:app];
            // DO cracking
            Cracker *cracker = [[Cracker alloc] init];
            [cracker prepareFromInstalledApp:app];

            NSString *ipapath = [cracker generateIPAPath];

            if ([cracker execute]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    app->finishedSuccessfully = true;
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
    NSLog(@"running operation count is %ld", (long)queue.operationCount);
}

- (void)updateCrackButtonState {
    if (self.tableView.indexPathsForSelectedRows) {
        crackBtn.enabled = YES;
    } else {
        crackBtn.enabled = NO;
    }
}

- (BOOL)inQueues:(ApplicationC *)app {
    if (![queueArray containsObject:app] && ![crackingArray containsObject:app] && ![doneArray containsObject:app]) {
        return NO;
    } else {
        return YES;
    }
}

@end
