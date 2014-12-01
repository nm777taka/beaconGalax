//
//  GXJoinedQuestCollectionViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXJoinedQuestCollectionViewCell.h"
#import "GXQuest.h"
#import "GXQuestList.h"

@implementation GXJoinedQuestCollectionViewCell

- (void)awakeFromNib
{
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.1f;
    self.layer.shadowRadius = 2.0f;
    
    self.titleLabel.textColor = [UIColor midnightBlueColor];
    self.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    self.createrIcon.layer.cornerRadius = 25.0f;
    self.createrIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.createrIcon.layer.borderWidth = 2.0f;
    
    self.ownerLabel.font = [UIFont boldFlatFontOfSize:15];
    self.ownerLabel.textColor = [UIColor midnightBlueColor];

}

#pragma mark - Setter
- (void)setQuest:(GXQuest *)quest
{
    _titleLabel.text = quest.title;
    _createrIcon.profileID = quest.fb_id;
    _ownerLabel.text = quest.createdUserName;
    NSDate *date = quest.createdDate;
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateStyle = NSDateFormatterShortStyle;
    NSString *formattedString = [df stringFromDate:date];
    _dateLabel.text = formattedString;
}

- (IBAction)showDetail:(id)sender {
    
    NSLog(@"call");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showInfo" object:self];
}
@end
