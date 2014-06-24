//
//  GXCustomCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *majorLable;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *accLabel;
@property (weak, nonatomic) IBOutlet UILabel *proxLabel;

@end
