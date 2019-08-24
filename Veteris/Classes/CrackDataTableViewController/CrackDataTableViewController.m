//
//  CrackDataTableViewController.m
//  Crackulous
//
//  Created by electimon on 6/3/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "CrackDataTableViewController.h"

@interface CrackDataTableViewController ()

@end

@implementation CrackDataTableViewController {
    NSDictionary *apps;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self obtainAppsAndSort];
    
    
}

- (IBAction)obtainAppsAndSort
{
    [self.refreshControl beginRefreshing];
    NSDictionary *plistResults = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Caches/com.apple.mobile.installation.plist"];
    
    apps = [plistResults valueForKey:@"User"];
    
    self.apps = [apps allValues];
    [self sortCrackableApps:apps];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)sortCrackableApps:(NSDictionary *)app {
    NSMutableDictionary *appDict =[[NSMutableDictionary alloc] init];
    for(id key in app) {
        if ([[[app objectForKey:key] allKeys] containsObject:@"ApplicationDSID"]) {
            
            NSMutableArray *item = [NSMutableArray array];
            
            [item addObject:[app objectForKey:key]];
            
            [appDict setObject:item forKey:key];
            
        }
    }
    self.sortedAppsKeys = [appDict allKeys];
    self.sortedApps = appDict;
    
}

@end
