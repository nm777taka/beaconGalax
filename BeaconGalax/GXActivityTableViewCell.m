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
        _userIcon.layer.cornerRadius = 25.0f;
        _userIcon.layer.borderColor = [UIColor midnightBlueColor].CGColor;
        _userIcon.layer.borderWidth = 2.0f;
    }
    
    return self;
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