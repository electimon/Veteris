//
//  AppInfo.h
//  Veteris
//
//  Created by electimon on 6/8/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppInfo : UIViewController <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UIImageView *appUIImage;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *appDeveloperNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *appDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reportButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (void)initialize:(NSString *)bundleID;
- (void)initialize:(NSString *)bundleID developer:(NSString *)developer name:(NSString *)name image:(UIImage *)image;
@end
