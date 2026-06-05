//
//  CategorySelectedViewController.m
//  Veteris
//
//  Created by electimon on 6/8/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "CategorySelectedViewController.h"

@implementation CategorySelectedViewController {
    NSString *categoryID;
    NSString *categoryName;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];

    self.navigationItem.title = categoryName;
    [self initialize:[NSString stringWithFormat:@"listing/category/%@", categoryID] skipIndicator:NO];
}

- (void)setCategoryID:(NSString *)category {
    categoryID = category;
}

- (void)setCategoryName:(NSString *)name {
    categoryName = name;
}

- (void)didSwipe:(UISwipeGestureRecognizer *)swipe {
    if ([[[UIDevice currentDevice] model] isEqual:@"iPad"]) {
        UINavigationController *naviController = self.navigationController;
        [naviController popViewControllerAnimated:YES];
    }
}

@end
