//
//  SearchViewController.m
//  Veteris
//
//  Created by Electimon on 12/22/18.
//  Copyright (c) 2018 1pwn. All rights reserved.
//
//

#import "SearchViewController.h"
#import "../FeaturedTableViewController/FeaturedTableViewCell.h"
#import "AppInfo.h"
#import "AppDelegate.h"
#import "../VAPIHelper.h"

@interface SearchViewController ()

@end

@implementation SearchViewController {
    NSMutableArray *searchResults;
    NSDictionary *apiResponse;
    NSMutableArray *apiResponseArray;
    NSOperationQueue *_searchOperationQueue;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search", @"Search");
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchBasicTableCell"];
    
    _searchOperationQueue = [NSOperationQueue new];
    _searchOperationQueue.maxConcurrentOperationCount = 1;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
   
    return NO;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [searchResults count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SearchBasicTableCell";
    
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (!searchResults || !searchResults.count){
    
    } else {
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"name"];
    }
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    // cancel any existing search
    [_searchOperationQueue cancelAllOperations];
        
    // begin new search
    [_searchOperationQueue addOperationWithBlock:^{
        NSUInteger length = [searchText length];
        if ((length > 3))
        {
            
            apiResponse = [VAPIHelper apiGet:[[NSString stringWithFormat:@"suggest?query=%@", searchText] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            
            
            if (apiResponse == nil) {
                apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"suggest?query=%@", searchText]];
                if (apiResponse == nil) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
                }
            }
            
            apiResponseArray = [apiResponse objectForKey:@"applications"];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [searchResults removeAllObjects];
                [self.searchDisplayController.searchResultsTableView reloadData];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            searchResults = apiResponseArray;
            [self.searchDisplayController.searchResultsTableView reloadData];
        });
    }];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    [self performSegueWithIdentifier:@"SearchViewAppInfoPush" sender:self];
    
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"SearchViewAppInfoPush"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        AppInfo *appinfo = segue.destinationViewController;
        
        apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"app/%@", [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"bundleid"]]];
        
        appinfo.appName = [apiResponse valueForKey:@"name"];
        appinfo.appDeveloperName = [apiResponse valueForKey:@"developer"];
        appinfo.appBundleID = [apiResponse valueForKey:@"bundleid"];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES];
    
}

@end
