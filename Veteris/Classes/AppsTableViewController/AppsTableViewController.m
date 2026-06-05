//
//  AppsTableViewController.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "AppsTableViewController.h"

@implementation AppsTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"AllApps", @"AllApps");
    [self initialize:@"listing/all"];
}
@end
