//
//  NSObject+BlocksWait.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BlocksWait)

+ (void)performBlock:(void(^)(void))block afterDelay:(NSTimeInterval)delay;

@end
