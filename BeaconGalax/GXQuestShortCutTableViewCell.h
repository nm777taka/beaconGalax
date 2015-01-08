//
//  GXQuestShortCutTableViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/08.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GXQuestShortCutTableViewCell;

@protocol GXQuestShortCutDelegate <NSObject>

- (void)doneCreateButton:(GXQuestShortCutTableViewCell *)cell;

@end

@interface GXQuestShortCutTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *shortCutImageView;
@property (weak, nonatomic) IBOutlet UILabel *shortCutTitle;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (nonatomic) id<GXQuestShortCutDelegate> delegate;
- (IBAction)createButtonPushed:(id)sender;

@end
