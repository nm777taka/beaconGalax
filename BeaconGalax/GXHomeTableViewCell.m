//
//  GXHomeTableViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/31.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXHomeTableViewCell.h"

@implementation GXHomeTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self.iconView.layer setCornerRadius:25];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
