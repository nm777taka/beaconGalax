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


const static CGFloat GXActivityCellBottomPadding = 10.0f;


@implementation GXActivityTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    
    return self;
}

//セッター(activityに設定される)
- (void)setActivity:(GXActivity *)activity
{
    //レイアウト関連
    _msgLabel.text = activity.msg;
    
}



@end
