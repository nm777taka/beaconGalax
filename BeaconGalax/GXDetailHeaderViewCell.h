//
//  GXDetailHeaderViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/31.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GXQuest;

@protocol GXHeaderCellDelegate <NSObject>

- (void)joinActionDelegate;
- (void)questStatrtDelegate;
- (void)questCacelDelegate;
- (void)questDeleteDelgate;

@end

@interface GXDetailHeaderViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FBProfilePictureView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UILabel *joinLabel;
@property (nonatomic,assign) id<GXHeaderCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
- (IBAction)updateAction:(id)sender;
- (IBAction)joinAction:(id)sender;
- (IBAction)deleteAction:(id)sender;

@property(nonatomic,strong) GXQuest *quest;

- (void)configureButtonForOwner;
- (void)configureButtonForJoiner:(BOOL)isJoined;


@end
