//
//  FeaturedTableViewCell.h
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeaturedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *developerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *appUIImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) int indicatorCounter;
@end
