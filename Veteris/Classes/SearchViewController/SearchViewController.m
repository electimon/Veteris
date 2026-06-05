//
//  SearchViewController.m
//  Veteris
//
//  Created by Electimon on 12/22/18.
//  Copyright (c) 2022 Electimon. All rights reserved.
//
//

#import "SearchViewController.h"
#import "../FeaturedTableViewController/FeaturedTableViewCell.h"
#import "../AppInfo/AppInfo.h"
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
    
    //[self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchBasicTableCell"];
    
    _searchOperationQueue = [NSOperationQueue new];
    _searchOperationQueue.maxConcurrentOperationCount = 1;
    
    // Type to search label
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:self.view.frame];
    typeLabel.text = @"Type to search!";
    typeLabel.alpha = 0.7;
    [typeLabel sizeToFit];
    [typeLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:typeLabel];
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
    // to limit network activity, reload half a second after last key press.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchExecute) object:nil];
    if (searchText.length > 2)
        [self performSelector:@selector(searchExecute) withObject:nil afterDelay:0.5];
    else {
        if ([searchResults count] != 0) {
            [searchResults removeAllObjects];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }
}

- (void)searchExecute {
    NSString *searchText = self.searchDisplayController.searchBar.text;
    if (((AppDelegate*)[[UIApplication sharedApplication] delegate]).debugOn) {
        NSLog(@"Search Text sent for suggestion = %@", searchText);
    }
    // cancel any existing search
    [_searchOperationQueue cancelAllOperations];
        
    // begin new search
    [_searchOperationQueue addOperationWithBlock:^{
        apiResponse = [VAPIHelper apiGet:[[NSString stringWithFormat:@"listing/suggest?query=%@", searchText] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        if (apiResponse == nil) {
            apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"listing/suggest?query=%@", searchText]];
            if (apiResponse == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        }
        
        apiResponseArray = [[apiResponse objectForKey:@"applications"] mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update only when this operation is the only operation in the queue
            if (_searchOperationQueue.operationCount == 1) {
                searchResults = apiResponseArray;
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        });
    }];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [self performSegueWithIdentifier:@"SearchViewAppInfoPush" sender:indexPath];
    
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"SearchViewAppInfoPush"]) {
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        AppInfo *appinfo = segue.destinationViewController;
        apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"listing/app/%@", [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"bundleid"]]	];
        
        appinfo.appName = [apiResponse valueForKey:@"name"];
        appinfo.appDeveloperName = [apiResponse valueForKey:@"developer"];
        appinfo.appBundleID = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"bundleid"];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES];
    
}

@end
