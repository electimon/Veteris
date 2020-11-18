//
//  CategoriesTableViewController.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "CategoriesTableViewController.h"
#import "CategoriesTableViewCell.h"
#import "../FeaturedTableViewController/FeaturedTableViewCell.h"
#import "../CategorySelectedViewController/CategorySelectedViewController.h"
#import "VAPIHelper.h"

@interface CategoriesTableViewController ()

@end

@implementation CategoriesTableViewController {
    NSDictionary *apiResponse;
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

    apiResponse = [VAPIHelper apiGet:@"categories"];
    
    if (apiResponse == nil) {
        apiResponse = [VAPIHelper apiGet:@"categories"];
        if (apiResponse == nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }
    
    self.navigationItem.title = @"Categories";
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[apiResponse objectForKey:@"categories"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoriesTableViewCell" forIndexPath:indexPath];
    
    cell.categoryLabel.text = [[[apiResponse objectForKey:@"categories"] objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"CategorySelectedPush"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        FeaturedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        CategorySelectedViewController *categorySelected = segue.destinationViewController;
        
        categorySelected.categoryID = [[NSString alloc] initWithString:[[[apiResponse objectForKey:@"categories"] objectAtIndex:indexPath.row] valueForKey:@"id"]];
        
    }
}
@end
