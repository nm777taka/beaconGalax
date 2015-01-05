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
//    NSDate *startDate = quest.startDate;
//    if (startDate) {
//        NSDateFormatter *df = [NSDateFormatter new];
//        df.dateFormat = @"MM/dd HH:mm";
//        NSString *formattedDate = [df stringFromDate:startDate];
//        self.startDateLabel.text = formattedDate;
//    } else {
//        self.startDateLabel.text = @"AnyTime";
//    }
}


@end
