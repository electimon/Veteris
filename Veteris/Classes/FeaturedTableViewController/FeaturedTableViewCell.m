//
//  FeaturedTableViewCell.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "FeaturedTableViewCell.h"

@implementation FeaturedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
