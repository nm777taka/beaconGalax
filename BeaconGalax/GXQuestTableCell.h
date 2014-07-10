//
//  GXQuestTableCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXQuestTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *questTitleLable;
@property (weak, nonatomic) IBOutlet UILabel *questDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *questLevelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvaterImageView;
- (IBAction)joinAction:(id)sender;

@end
