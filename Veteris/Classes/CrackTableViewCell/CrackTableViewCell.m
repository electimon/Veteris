//
//  CrackTableViewCell.m
//  Crackulous
//
//  Created by electimon on 6/3/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "CrackTableViewCell.h"

@implementation CrackTableViewCell
@synthesize cellImage;
@synthesize cellLabel;

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
