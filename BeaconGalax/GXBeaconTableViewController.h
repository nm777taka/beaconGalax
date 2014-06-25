//
//  GXBeaconTableViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXBeacon.h"


@interface GXBeaconTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,GXBeaconDelegate>

@property (weak, nonatomic) IBOutlet UITableView *beaconTable;
@property (weak, nonatomic) IBOutlet UILabel *bluetoothLabel;
@property (weak, nonatomic) IBOutlet UILabel *AuthLabel;

@end
