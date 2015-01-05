//
//  GXActivityTableViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXActivityTableViewCell.h"
#import "GXActivity.h"
#import "GXActivityList.h"

@implementation GXActivityTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
    }
    
    return self;
}

- (void)awakeFromNib
{
    self.userIcon.layer.cornerRadius = 5.0f;
}

//セッター(activityに設定される)
- (void)setActivity:(GXActivity *)activity
{
    //レイアウト関連
    _msgLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    _msgLabel.text = activity.msg;
    
    _name.font = [UIFont boldFlatFontOfSize:13];
    _name.text = activity.name;
    
    _dateLabel.text = activity.dateText;
    _userIcon.profileID = activity.fbID;
}

@end