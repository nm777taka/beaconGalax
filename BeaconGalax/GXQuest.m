//
//  GXQuest.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuest.h"

@implementation GXQuest

- (instancetype)initWithTitle:(NSString *)title fbID:(NSString *)fbID
{
    self = [super init];
    if (self) {
        _title = title;
        _fb_id = fbID;
    }
    
    return self;
}



@end
