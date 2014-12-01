
//
//  GXInvitedViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXInvitedViewCell.h"
#import "GXNotification.h"
#import "GXQuestList.h"
#import "GXQuest.h"


@implementation GXInvitedViewCell

- (void)awakeFromNib
{
    self.ownerName.font = [UIFont boldFlatFontOfSize:15];
    
    self.title.textColor = [UIColor midnightBlueColor];
    self.title.font = [UIFont boldFlatFontOfSize:16];
    
    self.ownerIcon.layer.cornerRadius = 25.0f;
    self.ownerIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ownerIcon.layer.borderWidth = 2.0f;
    
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.1f;
    self.layer.shadowRadius = 2.0f;


}

- (void)setQuest:(GXQuest *)quest
{
    _title.text = quest.title;
    _ownerName.text = quest.createdUserName;
    _ownerIcon.profileID = quest.fb_id;
    NSDate *date = quest.createdDate;
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateStyle = NSDateFormatterShortStyle;
    NSString *formattedString = [df stringFromDate:date];
    _createdDateLabel.text = formattedString;
}



- (IBAction)showInfo:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"questInfo" object:self];
}
@end
