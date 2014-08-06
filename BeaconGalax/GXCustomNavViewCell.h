//
//  GXCustomNavVIewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXCustomNavViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *viewNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *viewIcon;
@property (weak, nonatomic) IBOutlet UIView *indicator;

@end
