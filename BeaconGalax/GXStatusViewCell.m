//
//  GXStatusViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXStatusViewCell.h"
#import "GXQuest.h"
#import "GXQuestList.h"

@implementation GXStatusViewCell

- (void)awakeFromNib {
    // Initialization code
    self.title.font = [UIFont boldFlatFontOfSize:15];
    self.startDateLabel.font = [UIFont boldFlatFontOfSize:13];
    self.questStatusLabel.font = [UIFont boldFlatFontOfSize:13];
    self.questStatusLabel.textColor = [UIColor darkGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setQuest:(GXQuest *)quest
{
    //タイトル
    self.title.text = quest.title;
    //スタート時間
    if (quest.startDateString) {
        NSString *dateLabelText = [NSString stringWithFormat:@"%@に開始予定",quest.startDateString];
        self.startDateLabel.text = dateLabelText;
    } else {
        self.startDateLabel.text = @"AnyTime";
    }
    
    if (quest.isStarted) {
        self.questStatusLabel.text = @"挑戦中";
    } else {
        self.questStatusLabel.text = @"募集中";
    }
}


@end
