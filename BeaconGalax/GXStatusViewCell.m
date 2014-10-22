//
//  GXStatusViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXStatusViewCell.h"

@implementation GXStatusViewCell

- (void)awakeFromNib {
    // Initialization code
    self.title.font = [UIFont boldFlatFontOfSize:15];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
