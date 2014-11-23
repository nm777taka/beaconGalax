//
//  NSObject+BlocksWait.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "NSObject+BlocksWait.h"

@implementation NSObject (BlocksWait)

+ (void)executeBlock__:(void(^)(void))block
{
    block();
}

+ (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(executeBlock__:) withObject:[block copy] afterDelay:delay];
    
}

@end
