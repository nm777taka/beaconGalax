//
//  GXCustomSectionHeader.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXCustomSectionHeader : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *identifierLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@end
