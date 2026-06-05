//
//  CrackTableViewCell.h
//  Crackulous
//
//  Created by electimon on 6/3/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CrackTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellVersionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cellIndicator;

@end
