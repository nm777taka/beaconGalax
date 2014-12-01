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
    //label
    self.createrName.font = [UIFont boldFlatFontOfSize:15];
    self.createrName.textColor = [UIColor midnightBlueColor];
    self.titleLable.textColor = [UIColor midnightBlueColor];
    self.titleLable.font = [UIFont boldFlatFontOfSize:16];
    
    self.createrIcon.layer.cornerRadius = 25.0f;
    self.createrIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.createrIcon.layer.borderWidth = 2.0f;
    
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
    //レイアウト寒冷
    _titleLable.text = quest.title;
    _createrIcon.profileID = quest.fb_id;
    _createrName.text = quest.createdUserName;
    
    NSDate *date = quest.createdDate;
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateStyle = NSDateFormatterShortStyle;
    NSString *formattedDateString = [df stringFromDate:date];
    _createdDateLable.text = formattedDateString;
    
}

- (IBAction)showInfo:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showInfo" object:self];
}
@end
