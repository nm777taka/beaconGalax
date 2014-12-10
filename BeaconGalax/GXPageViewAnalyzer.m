//
//  GXPageViewAnalyzer.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXPageViewAnalyzer.h"
#import "GXBucketManager.h"

@implementation GXPageViewAnalyzer

+ (GXPageViewAnalyzer *)shareInstance
{
    static GXPageViewAnalyzer *sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXPageViewAnalyzer alloc] initSharedSingleton];
    });
    
    return sharedSingleton;
}

- (id)initSharedSingleton
{
    self = [super init];
    if (self) {
        //init
    }
    
    return self;
}

- (void)setPageView:(NSString *)viewControllerName
{
    //pageViewを格納するバケットを取得
    KiiBucket *pageViewBucket = [GXBucketManager sharedManager].pageViewBucket;
    if (pageViewBucket == nil) {
        //まだ何もはいってない状態はnilになる
        KiiObject *obj = [pageViewBucket createObject];
        [obj setObject:viewControllerName forKey:@"viewName"];
        [obj setObject:@1 forKey:@"viewCount"];
        [obj saveWithBlock:^(KiiObject *object, NSError *error) {
            //
            NSLog(@"first-view-count");
        }];
        
    } else {
        //同じviewNameがあるかチェック
        //あったらそのviewの数を増やす
        KiiClause *clause = [KiiClause equals:@"viewName" value:viewControllerName];
        KiiQuery *query = [KiiQuery queryWithClause:clause];
        [pageViewBucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
            
            if (!error) {
                
                if (results.count == 0) {
                    KiiObject *obj = [pageViewBucket createObject];
                    [obj setObject:viewControllerName forKey:@"viewName"];
                    [obj setObject:@1 forKey:@"viewCount"];
                    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
                        NSLog(@"newView++");
                    }];
                } else {
                    KiiObject *currentObj = results.firstObject;
                    int currentViewNum = [[currentObj getObjectForKey:@"viewCount"] intValue];
                    currentViewNum++;
                    [currentObj setObject:[NSNumber numberWithInt:currentViewNum] forKey:@"viewCount"];
                    [currentObj saveWithBlock:^(KiiObject *object, NSError *error) {
                        NSLog(@"CurrentView++");
                    }];
                }
                
            } else {
                NSLog(@"ない");
            }
        }];

    }
    
    
}
@end
