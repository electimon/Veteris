//
//  AppsTableViewController.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "AppsTableViewController.h"
#import "../FeaturedTableViewController/FeaturedTableViewCell.h"
#import "../AppInfo/AppInfo.h"
#import "../VAPIHelper.h"
#import "../../AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "../../SVProgressHUD/SVProgressHUD.h"

@interface AppsTableViewController ()

@end

@implementation AppsTableViewController {
    NSArray *apiResponseArray;
    NSDictionary *apiResponse;
    NSOperationQueue *queue;
    AppDelegate *delegate;
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
    
    delegate = [[UIApplication sharedApplication] delegate];
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        apiResponse = [VAPIHelper apiGet:@"listing/all"];
    
        apiResponseArray = [apiResponse objectForKey:@"applications"];
        if (apiResponse == nil) {
            apiResponse = [VAPIHelper apiGet:@"listing/all"];
            if (apiResponse == nil) {
                [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        }
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [apiResponseArray count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FeaturedTableViewCell";
    
    FeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.tag = indexPath.row;
    
    [cell.activityIndicator startAnimating];
    cell.appNameLabel.text = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    cell.developerNameLabel.text = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"developer"];
    
    cell.versionLabel.text = [NSString stringWithFormat:@"Version: %@", [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"version"]];
    if (cell.appUIImage.image == nil) {
        NSString *iconURL = [NSString stringWithFormat:@"%@%@", delegate.apiBaseURL, [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"iconurl"]];
        UIImage *image = [delegate.imageCache objectForKey:iconURL];
        if (image) {
            cell.appUIImage.image = image;
            [cell.activityIndicator stopAnimating];		
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSInteger tag = cell.tag;
                NSURL *imageURL = [NSURL URLWithString:[iconURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                NSData* imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (!cell.appUIImage.image && cell.tag == tag) {
                        [cell.activityIndicator stopAnimating];
                        cell.appUIImage.image = [UIImage imageWithData:imageData];
                        if (cell.appUIImage.image) {
                            [delegate.imageCache setObject:cell.appUIImage.image forKey:iconURL];
                        }
                    }
                    cell.indicatorCounter = 1;
                    cell.appUIImage.layer.masksToBounds = YES;
                    cell.appUIImage.layer.cornerRadius = 13.0;
                }];
            });
        }
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"AppsAppInfoPush"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        FeaturedTableViewCell *cell = (FeaturedTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        AppInfo *appinfo = segue.destinationViewController;
        
        appinfo.appName = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        appinfo.appDeveloperName = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"developer"];
        appinfo.appBundleID = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"bundleid"];
        
        appinfo.appImage = cell.appUIImage.image;
        
    }
}

@end
