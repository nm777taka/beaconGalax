//
//  GXCollectionViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCollectionViewCell.h"
#import <FlatUIKit/FlatUIKit.h>

@implementation GXCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        

        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor turquoiseColor];
    self.blackView.backgroundColor = [[UIColor wetAsphaltColor] colorWithAlphaComponent:0.7];
    
    self.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    self.titleLabel.textColor = [UIColor cloudsColor];
    
    self.descriptionLabel.font = [UIFont boldFlatFontOfSize:10];
    self.descriptionLabel.textColor = [UIColor cloudsColor];

}


@end
