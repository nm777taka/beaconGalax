//
//  GXActionAnalyzer.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXActionAnalyzer.h"
#import "GXBucketManager.h"
#import "GXAction.h"

@implementation GXActionAnalyzer

+ (GXActionAnalyzer *)sharedInstance
{
    static GXActionAnalyzer *sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXActionAnalyzer alloc] initSingleton];
    });
    
    return sharedSingleton;
}

- (id)initSingleton
{
    self = [super init];
    if (self) {
        //init
    }
    
    return self;
}

//アクション登録
- (void)setActionName:(NSString *)name
{
    KiiBucket *bucket = [GXBucketManager sharedManager].userActionBucket;
    
    if (bucket == nil) {
        NSLog(@"bucket == nill");
        KiiObject *obj = [bucket createObject];
        [obj setObject:name forKey:@"actionName"];
        [obj setObject:@1 forKey:@"actionCount"];
        [obj saveWithBlock:^(KiiObject *object, NSError *error) {
            if (!error) {
                NSLog(@"newAction++");
            } else {
            }
        }];
        
    } else {
        KiiClause *clause = [KiiClause equals:@"actionName" value:name];
        KiiQuery *query = [KiiQuery queryWithClause:clause];
        [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
            
            if (!error) {
                
                KiiObject *obj = results.firstObject;
                if (obj == nil) {
                    KiiObject *obj = [bucket createObject];
                    [obj setObject:name forKey:@"actionName"];
                    [obj setObject:@1 forKey:@"actionCount"];
                    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
                        
                    }];

                } else {
                    
                    int actionCount = [[obj getObjectForKey:@"actionCount"] intValue];
                    actionCount++;
                    [obj setObject:[NSNumber numberWithInt:actionCount] forKey:@"actionCount"];
                    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
                        if (!error) {
                            NSLog(@"action++");
                        }
                    }];
                }
                
            } else {
            }
        }];
    }
}


@end
