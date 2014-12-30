//
//  GXDetailHeaderViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/31.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXDetailHeaderViewCell.h"
#import "GXQuest.h"
#import "GXQuestList.h"

@implementation GXDetailHeaderViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)updateAction:(id)sender {
}

- (IBAction)joinAction:(id)sender {
}

- (IBAction)deleteAction:(id)sender {
}

#pragma mark - Data

- (void)setQuest:(GXQuest *)quest
{
    self.nameLabel.text = quest.createdUserName;
    self.titleLabel.text = quest.title;
    self.iconView.profileID = quest.fb_id;
    self.detailTextView.text = quest.quest_des;
    
    NSDate *createdDate = quest.createdDate;
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy/MM/dd HH:mm";
    NSString *dfString = [df stringFromDate:createdDate];
    self.dateLabel.text = dfString;
    
}
@end
