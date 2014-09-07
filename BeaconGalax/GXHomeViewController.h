//
//  GXHomeViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXHomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *questTableView;

@end
