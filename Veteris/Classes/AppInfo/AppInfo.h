//
//  AppInfo.h
//  Veteris
//
//  Created by electimon on 6/8/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppInfo : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UIImageView *appUIImage;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *appDeveloperNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *appDescriptionLabel;
@property (weak, nonatomic) NSString *appName;
@property (weak, nonatomic) NSString *appDeveloperName;
@property (weak, nonatomic) NSString *appBundleID;
@property (strong, nonatomic) UIImage *appImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reportButton;
@property (strong, nonatomic) UIAlertView *alertView;
- (IBAction)reportButtonPressed:(id)sender;
@end
