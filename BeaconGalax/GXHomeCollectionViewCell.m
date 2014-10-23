//
//  GXHomeCollectionViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/05.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXHomeCollectionViewCell.h"
#import "GXNotification.h"

@implementation GXHomeCollectionViewCell

- (void)awakeFromNib
{
    self.acceptButton.buttonColor = [UIColor alizarinColor];
    self.acceptButton.shadowColor = [UIColor pomegranateColor];
    self.acceptButton.shadowHeight = 3.0f;
    self.acceptButton.cornerRadius = 6.0f;
    self.acceptButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.acceptButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.acceptButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [self.acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
    
    //label
    self.createrName.font = [UIFont boldFlatFontOfSize:15];
    self.createrName.textColor = [UIColor midnightBlueColor];
    self.questTypeLabel.font = [UIFont boldFlatFontOfSize:14];
    self.questTypeLabel.textColor = [UIColor midnightBlueColor];
    
    self.titleLable.textColor = [UIColor midnightBlueColor];
    self.titleLable.font = [UIFont boldFlatFontOfSize:16];
    
    //view
    self.questTypeColorView.backgroundColor = [UIColor turquoiseColor];
    
}

- (IBAction)joinAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestJoinNotification object:self];
}

@end
