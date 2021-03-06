//
//  GXPointManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/06.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXPointManager : NSObject

@property (nonatomic,strong) KiiBucket *userPointBucket;

+ (GXPointManager *)sharedInstance;
@property (nonatomic) KiiObject *currentPoint;

//アプリ内アクションに対する報酬
- (void)getCreateQuestPoint;
- (void)getInviteQuestPoint;

//クエストクリアに対する報酬ポイントをかえす
- (float)getQuestClearPoint:(KiiObject *)cleardQuest;

//取得したポイントを渡して、ステータスを更新する
- (void)refreshPoint:(int)point;


//
- (int)getCurrentPoint;
- (void)checkRank;
- (NSDictionary *)checkNextRank;


@end
