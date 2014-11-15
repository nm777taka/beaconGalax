//
//  GXActivityList.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>

@class GXActivity;

//Delegate
//UITableViewでデータ取得後にテーブルを更新するため
@protocol GXActivityListDelegate <NSObject>

- (void)activityListDidLoad;

@end


@interface GXActivityList : NSObject

@property (nonatomic) BOOL loading;
@property (nonatomic,strong)KiiQuery *nextQuery;


+ (GXActivityList *)sharedInstance;
- (instancetype)initWithDelegate:(id<GXActivityListDelegate>)delegate;

- (NSUInteger)count;
- (GXActivity *)activityAtIndex:(NSUInteger)index;

//通信
- (void)requestAsynchronous;
- (void)requestMoreAsynchronous;

//登録(Bucket)
//クエストアクティブ
- (void)registerQuestActivity:(NSString *)name
                        title:(NSString *)text
                         fbid:(NSString *)fbid;



@end
