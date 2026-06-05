//
//  CategorySelectedViewController.m
//  Veteris
//
//  Created by electimon on 6/8/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "CategorySelectedViewController.h"
#import "../FeaturedTableViewController/FeaturedTableViewCell.h"
#import "../AppInfo/AppInfo.h"
#import "../VAPIHelper.h"
#import "../../AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface CategorySelectedViewController ()

@end

@implementation CategorySelectedViewController {
    NSDictionary *apiResponse;
    NSArray *apiResponseArray;
    NSOperationQueue *queue;
    AppDelegate *delegate;
}
@synthesize categoryID;
@synthesize categoryName;

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
        [VAPIHelper debugLog:@"CategorySelectedViewController" message:@"wtf moment"];
        exit(EXIT_FAILURE);
    }
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    self.navigationItem.title = categoryName;
    
    delegate = [[UIApplication sharedApplication] delegate];
    
    queue = [[NSOperationQueue alloc] init];
    
    apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"listing/category/%@", self.categoryID]];
    
    if (apiResponse == nil) {
        apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"listing/category/%@", self.categoryID]];
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
    if ([segue.identifier isEqual:@"CategorySelectedAppInfoPush"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        FeaturedTableViewCell *cell = (FeaturedTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        AppInfo *appinfo = segue.destinationViewController;
        
        appinfo.appName = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        appinfo.appDeveloperName = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"developer"];
        appinfo.appBundleID = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"bundleid"];
        appinfo.appImage = cell.appUIImage.image;
        
    }
}

- (void)didSwipe:(UISwipeGestureRecognizer*)swipe {
    if ([[[UIDevice currentDevice] model]  isEqual: @"iPad"]) {
        UINavigationController *naviController = self.navigationController;
        [naviController popViewControllerAnimated:YES];
    }
}

@end
