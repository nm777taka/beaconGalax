//
//  GXHomeCollectionViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/05.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXHomeCollectionViewCell : UICollectionViewCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UILabel *rewardLabel;
- (IBAction)joinAction:(id)sender;

@end
