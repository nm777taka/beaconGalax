//
//  GXHomeCollectionViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/05.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXHomeCollectionViewCell.h"
#import "GXQuest.h"
#import "GXQuestList.h"


@implementation GXHomeCollectionViewCell

- (void)awakeFromNib
{
    //userName
    self.createrName.font = [UIFont boldFlatFontOfSize:15];
    self.createrName.textColor = [UIColor midnightBlueColor];
    
    //title
    self.titleLable.textColor = [UIColor midnightBlueColor];
    self.titleLable.font = [UIFont boldFlatFontOfSize:13];
    
    //questStatus
    self.questStatusLabel.font = [UIFont boldFlatFontOfSize:13];
    self.questStatusLabel.layer.cornerRadius = 5.0f;
    self.questStatusLabel.backgroundColor = [UIColor turquoiseColor];
    self.questStatusLabel.textColor = [UIColor whiteColor];
    self.questStatusLabel.textAlignment = NSTextAlignmentCenter;
    
    self.createrIcon.layer.cornerRadius = 5.0f;

    
    //drop shadow
    //ドロップシャドウ
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.1f;
    self.layer.shadowRadius = 2.0f;
    
}

#pragma mark - Setter
- (void)setQuest:(GXQuest *)quest
{
    //レイアウト
    _titleLable.text = quest.title;
    _createrIcon.profileID = quest.fb_id;
    _createrName.text = quest.createdUserName;
    
    NSDate *date = quest.createdDate;
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy/MM/dd HH:mm"; //ここでGMTに変換される！
    NSString *formattedDateString = [df stringFromDate:date];
    _createdDateLable.text = formattedDateString;
    
    if (quest.isCompleted) {
        [self changeStatusForQuestCompleted];
        return;
    }
    
    if (quest.isStarted) {
        [self changeStatusForQuestStarting];
        return;
    }
    
    [self changeStatsuForQuestInviting];
}


- (IBAction)showInfo:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showInfo" object:self];
}

#pragma mark - クエストステータス変更メソッド
- (void)changeStatsuForQuestInviting
{
    self.questStatusLabel.text = @"募集中";
    self.questStatusLabel.backgroundColor = [UIColor turquoiseColor];
    self.questStatusLabel.textColor = [UIColor whiteColor];
}

- (void)changeStatusForQuestStarting
{
    self.questStatusLabel.text = @"挑戦中";
    self.questStatusLabel.textColor = [UIColor whiteColor];
    self.questStatusLabel.backgroundColor = [UIColor alizarinColor];
}

- (void)changeStatusForQuestCompleted
{
    self.questStatusLabel.text = @"クリア";
    self.questStatusLabel.backgroundColor = [UIColor amethystColor];
    self.questStatusLabel.textColor = [UIColor whiteColor];
}
@end
