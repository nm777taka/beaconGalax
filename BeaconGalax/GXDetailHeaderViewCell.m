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
#import "GXNotification.h"

@implementation GXDetailHeaderViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - ButtonAction
//とりあえず保留
- (IBAction)updateAction:(id)sender
{
    //作成者以外がupdateできる
    
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

#pragma mark - Configure Button
- (void)configureButtonForOwner
{
    //JoinButton
    self.joinButton.layer.cornerRadius = 5.0f;
    self.joinButton.layer.borderColor = [UIColor turquoiseColor].CGColor;
    self.joinButton.layer.borderWidth = 2.0f;
    
    [self.joinButton setTitle:@"START" forState:UIControlStateNormal];
    [self.joinButton setTitle:@"START" forState:UIControlStateHighlighted];
    [self.joinButton bk_addEventHandler:^(id sender) {
        if ([self.delegate respondsToSelector:@selector(questStatrtDelegate:)]) {
            [self.delegate questStatrtDelegate:self.quest];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    //DeleteButton
    self.deleteButton.enabled = YES;
    self.deleteButton.layer.cornerRadius = 5.0f;
    self.deleteButton.backgroundColor = [UIColor turquoiseColor];
    self.deleteButton.alpha = 1.0f;
    
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateHighlighted];
    [self.deleteButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [self.deleteButton bk_addEventHandler:^(id sender) {
        //
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configureButtonForJoiner:(BOOL)isJoined
{
    if (isJoined) {
        
        //JoinedButton
        self.joinButton.layer.cornerRadius = 5.0f;
        self.joinButton.backgroundColor = [UIColor turquoiseColor];

        [self.joinButton setTitle:@"START" forState:UIControlStateNormal];
        [self.joinButton setTitle:@"START" forState:UIControlStateHighlighted];
        [self.joinButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
        [self.joinButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
        [self.joinButton bk_addEventHandler:^(id sender) {
            if ([self.delegate respondsToSelector:@selector(questStatrtDelegate:)]) {
                [self.delegate questStatrtDelegate:self.quest];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        //DeleteButton
        self.deleteButton.enabled = YES;
        self.deleteButton.layer.cornerRadius = 5.0f;
        self.deleteButton.backgroundColor = [UIColor turquoiseColor];
        self.deleteButton.alpha = 1.0f;
        
        [self.deleteButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.deleteButton setTitle:@"Cancel" forState:UIControlStateHighlighted];
        [self.deleteButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
        [self.deleteButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
        [self.deleteButton bk_addEventHandler:^(id sender) {
            if ([self.delegate respondsToSelector:@selector(questCacelDelegate:)]) {
                [self.delegate questCacelDelegate:self.quest];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    
        
    } else {
        
        //JoinButton
        self.joinButton.layer.cornerRadius = 5.0f;
        self.joinButton.layer.borderColor = [UIColor turquoiseColor].CGColor;
        self.joinButton.layer.borderWidth = 2.0f;
        
        [self.joinButton setTitle:@"JOIN" forState:UIControlStateNormal];
        [self.joinButton setTitle:@"JOIN" forState:UIControlStateHighlighted];
        [self.joinButton setTitleColor:[UIColor turquoiseColor] forState:UIControlStateNormal];
        [self.joinButton setTitleColor:[UIColor turquoiseColor] forState:UIControlStateHighlighted];
        [self.joinButton bk_addEventHandler:^(id sender) {
            if ([self.delegate respondsToSelector:@selector(joinActionDelegate:)]) {
                [self.delegate joinActionDelegate:self.quest];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        //DeleteButton
        self.deleteButton.enabled = NO;
        self.deleteButton.backgroundColor = [UIColor lightGrayColor];
        self.deleteButton.alpha = 0.8f;

    }
}
@end
