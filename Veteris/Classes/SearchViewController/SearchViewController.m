//
//  SearchViewController.m
//  Veteris
//
//  Created by Electimon on 12/22/18.
//  Copyright (c) 2022 Electimon. All rights reserved.
//
//

#import "SearchViewController.h"
#import "../AppInfo/AppInfo.h"
#import "../VAPIHelper/VAPIHelper.h"
#import "../../SVProgressHUD/SVProgressHUD.h"
#import "../ProtoStack.h"
#import "../Protos/Suggestion.h"
@implementation SearchViewController {
    NSMutableArray *searchResults;
    NSArray *results;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Type to search label
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:self.view.frame];
    typeLabel.text = NSLocalizedString(@"TypeToSearch", nil);
    typeLabel.alpha = 0.7;
    [typeLabel sizeToFit];
    [typeLabel setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    [self.view addSubview:typeLabel];
    self.definesPresentationContext = YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    // need to reset the frame
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SearchBasicTableCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Suggestion *suggestion = [searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = suggestion.name;
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // to limit network activity, reload half a second after last key press.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchExecute) object:nil];
    if (searchText.length > 2)
        [self performSelector:@selector(searchExecute) withObject:nil afterDelay:0.3];
    else {
        if ([searchResults count] != 0) {
            [searchResults removeAllObjects];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }
}

- (void)searchExecute {
    NSString *searchText = self.searchDisplayController.searchBar.text;
    debugLog(@"Searching for %@", searchText);
    // begin new search
    [VAPISS getMessage:[NSString stringWithFormat:@"listing/suggest?query=%@", [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] completion:^(NSData *data, NSError *error){
        if (error == nil) {
            searchResults = (NSMutableArray *)(CFBridgingRelease(decode([data bytes], [data length], SuggestionsResponse)));
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchDisplayController.searchResultsTableView reloadData];
            });
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"SearchViewAppInfoPush" sender:indexPath];

    self.navigationController.navigationBarHidden = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"SearchViewAppInfoPush"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        AppInfo *appinfo = segue.destinationViewController;
        Suggestion *suggestion = [searchResults objectAtIndex:indexPath.row];
        [appinfo initialize:suggestion.bundleid];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

@end
