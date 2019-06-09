//
//  FeaturedTableViewController.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "FeaturedTableViewController.h"
#import "FeaturedTableViewCell.h"
#import "AppInfo.h"
#import "VAPIHelper.h"
#import "../../AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface FeaturedTableViewController ()

@end

@implementation FeaturedTableViewController {
    NSArray *apiResponseArray;
    NSDictionary *apiResponse;
    NSOperationQueue *queue;
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
    
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    
    NSLog(@"VAPIstring = %@", appdelegate.VAPIDeviceString);
    
    apiResponse = [VAPIHelper apiGet:@"listing/recommended"];
    
    apiResponseArray = [apiResponse objectForKey:@"applications"];
    
    if (apiResponse == nil) {
        apiResponse = [VAPIHelper apiGet:@"listing/recommended"];
        if (apiResponse == nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }
    
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
    
    FeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell.indicatorCounter == 0) {
    [cell.activityIndicator startAnimating];
    }
    cell.appNameLabel.text = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    cell.developerNameLabel.text = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"developer"];
    if (cell.appUIImage.image == nil) {
    [queue addOperationWithBlock:^{
        NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/128x0w.jpg",[[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"iconurl"]]];
       
        NSData* imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [cell.activityIndicator stopAnimating];
            cell.appUIImage.image = [UIImage imageWithData:imageData];
            cell.indicatorCounter = 1;
            cell.appUIImage.layer.masksToBounds = YES;
            cell.appUIImage.layer.cornerRadius = 13.0;
            [tableView reloadData];
            
        }];
    }];
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"FeaturedAppInfoPush"]) {
        NSLog(@"Veteris: Pushing AppInfo");
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        FeaturedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        AppInfo *appinfo = segue.destinationViewController;
        
        appinfo.appName = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        appinfo.appDeveloperName = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"developer"];
        appinfo.appBundleID = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"bundleid"];        
        appinfo.appImage = cell.appUIImage.image;
        
    }
}

@end
