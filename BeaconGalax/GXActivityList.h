//
//  GXActivityList.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GXActivity;

//Delegate
//UITableViewでデータ取得後にテーブルを更新するため
@protocol GXActivityListDelegate <NSObject>

- (void)activityListDidLoad;

@end


@interface GXActivityList : NSObject

- (instancetype)initWithDelegate:(id<GXActivityListDelegate>)delegate;

- (NSUInteger)count;
- (GXActivity *)activityAtIndex:(NSUInteger)index;

//通信
- (void)requestAsynchronous;

@end
