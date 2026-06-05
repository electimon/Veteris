//
//  HomeTableViewCell.m
//  Veteris
//
//  Created by electimon on 1/5/24.
//  Copyright (c) 2024 1pwn. All rights reserved.
//

#import "HomeTableViewCell.h"

@implementation HomeTableViewCell
@synthesize contentLabel;
@synthesize authorLabel;

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
