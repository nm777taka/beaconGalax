//
//  GXExeQuestManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/03.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>


@interface GXExeQuestManager : NSObject


+ (GXExeQuestManager *)sharedManager;

////scope_user
//@property (nonatomic,retain) KiiObject *questAtJoinedMultiBucket;
//@property (nonatomic,retain) KiiObject *questAtJoinedOneBucket;
//
////scope_app
//@property (nonatomic,retain) KiiObject *questAtInvitedBucket;

//全部ひとつにまとめられるかも
/*参照するobjはひとつで状況によって親Bucketが違う
 
 注意：クリアしたクエストをもう一回やる場合は対応必要
        そのクエストをnowExeにいれて消すとcleardからも消える（でも書き込んでから消すから要素数は変わらないかな?)
 
 */
@property (nonatomic,retain) KiiObject *nowExeQuest;

- (void)clearNowExeQuest;

////App
- (void)startQuestAtInvitedBucket:(KiiObject *)obj;
//- (void)completeQuestAtInviteBucket;
//
////User
//- (void)completeQuestAtJoinedMultiQuestBucket;
//- (void)registerClearBucket:(KiiObject *)obj;

@end
