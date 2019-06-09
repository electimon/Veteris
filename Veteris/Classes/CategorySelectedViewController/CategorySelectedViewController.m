//
//  CategorySelectedViewController.m
//  Veteris
//
//  Created by electimon on 6/8/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "CategorySelectedViewController.h"
#import "../FeaturedTableViewController/FeaturedTableViewCell.h"
#import "../AppInfo/AppInfo.h"
#import "../VAPIHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface CategorySelectedViewController ()

@end

@implementation CategorySelectedViewController {
    NSDictionary *apiResponse;
    NSArray *apiResponseArray;
    NSOperationQueue *queue;
}
@synthesize categoryID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.categoryID == nil) {
        NSLog(@"Excuse me what?");
        exit(EXIT_FAILURE);
    }
    
    queue = [[NSOperationQueue alloc] init];
    
    apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"listing/category/%@", self.categoryID]];
    
    if (apiResponse == nil) {
        apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"category/%@", self.categoryID]];
        if (apiResponse == nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }
    
    apiResponseArray = [apiResponse objectForKey:@"applications"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[apiResponse objectForKey:@"applications"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
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
    if ([segue.identifier isEqual:@"CategorySelectedAppInfoPush"]) {
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
