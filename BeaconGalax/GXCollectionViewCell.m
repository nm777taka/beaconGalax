//
//  GXCollectionViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCollectionViewCell.h"
#import "FUIButton+GXTheme.h"
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

#pragma mark - UI
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor turquoiseColor];
    
    
    self.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    self.titleLabel.textColor = [UIColor cloudsColor];
    
    self.descriptionLabel.font = [UIFont boldFlatFontOfSize:10];
    self.descriptionLabel.textColor = [UIColor cloudsColor];
    
    //クエスト参加ボタン
    [FUIButton gxQuestTheme:self.joinButton];
    
    
}


@end
