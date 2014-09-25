//
//  GXHomeTableViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/31.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXHomeTableViewCell.h"
#import "GXNotification.h"

@implementation GXHomeTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.joinButton.layer.cornerRadius = 5.0f;
    self.joinButton.layer.borderColor = [UIColor cyanColor].CGColor;
    self.joinButton.layer.borderWidth = 1.0f;
    self.joinButton.backgroundColor = [UIColor clearColor];
    [self.joinButton bk_addEventHandler:^(id sender) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"確認" message:@"このクエストに参加しますか" delegate:self cancelButtonTitle:@"やめる" otherButtonTitles:@"参加", nil];
        
        [alert show];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.fbUserIcon.layer.cornerRadius = 25.0;
    self.fbUserIcon.layer.borderWidth = 1.0;
    self.fbUserIcon.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - AlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
            
        case 1:
            NSLog(@"^--->");
            [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestJoinNotification object:self];
            break;
            
        default:
            break;
    }
}

@end
