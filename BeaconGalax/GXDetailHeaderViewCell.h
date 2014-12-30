//
//  GXDetailHeaderViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/31.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXDetailHeaderViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UILabel *joinLabel;
- (IBAction)updateAction:(id)sender;
- (IBAction)joinAction:(id)sender;
- (IBAction)deleteAction:(id)sender;

@end
