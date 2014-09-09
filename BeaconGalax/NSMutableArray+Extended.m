//
//  NSMutableArray+Extended.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "NSMutableArray+Extended.h"
#include <objc/runtime.h>
@implementation NSMutableArray (Extended)

//アコーディオンが開いているかどうか設定

- (BOOL)isExtended
{
    return [objc_getAssociatedObject(self, @"extended") boolValue];
}

- (void)setExtended:(BOOL)extended
{
    objc_setAssociatedObject(self, @"extended",[NSNumber numberWithLongLong:extended],OBJC_ASSOCIATION_ASSIGN);
}





@end