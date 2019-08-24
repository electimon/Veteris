//
//  CrackTableViewController.h
//  Crackulous
//
//  Created by electimon on 6/3/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CrackTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *apps; // of the MobileInstallation cache plist NSDictionaries
@property (nonatomic, strong) NSDictionary *sortedApps; // of the Sorted crackable apps in the MobileInstallation cache plist
@property (nonatomic, strong) NSArray *sortedAppsKeys; // of the Sorted crackable apps bundleids
@end
