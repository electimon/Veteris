//
//  FeaturedTableViewController.h
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeaturedTableViewController : UITableViewController<UIAlertViewDelegate>
- (IBAction)signinButtonPressed:(id)sender;
- (IBAction)registerButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *registerButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signinButton;

@end
