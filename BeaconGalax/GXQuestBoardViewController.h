//
//  GXQuestBoardViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
@interface GXQuestBoardViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *questTable;

@end
