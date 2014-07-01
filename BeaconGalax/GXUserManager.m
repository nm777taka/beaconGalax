//
//  GXUserManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/01.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXUserManager.h"

@implementation GXUserManager

+ (GXUserManager *)sharedManager
{
    static GXUserManager *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXUserManager alloc]initSharedInstance];
    });
    
    return sharedSingleton;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        //init
    }
    
    return self;
}


#pragma mark UserFiledC
- (void)addCalamAtSignup:(KiiUser *)user
{
    //とりあえずログインしたら近くにいることにする
    //将来的にはbeaconでregionに入った時にyes
    //でた時にnoにする
    NSError *error = nil;
    
    [user setObject:@YES forKey:@"isNear"];
    [user setObject:@YES forKey:@"isMember"];
//    [user saveWithBlock:^(KiiUser *user, NSError *error) {
//        if (error) {
//            NSLog(@"addCalamError:%@",error);
//        } else {
//            NSLog(@"add Calam successed");
//        }
//    }];
    [user saveSynchronous:&error];
    if (error) {
        NSLog(@"error : %@",error);
    }
    
}


@end
