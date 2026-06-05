//
//  FeaturedTableViewController.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "FeaturedTableViewController.h"

@implementation FeaturedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Featured", @"Featured");
    [self initialize:@"listing/recommended"];    
}
@end
