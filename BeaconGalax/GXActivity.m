//
//  GXActivity.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXActivity.h"

@implementation GXActivity

- (instancetype)initWithName:(NSString *)name text:(NSString *)text iconID:(NSString *)iconID dateText:(NSString *)dateText
{
    self = [super init];
    if (self) {
        _name = name;
        _msg = text;
        _fbID = iconID;
        _dateText = dateText;
    }
    
    return self;
}

@end
