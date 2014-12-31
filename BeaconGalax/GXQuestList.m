//
//  GXQuestList.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestList.h"
#import "GXBucketManager.h"

#import "GXDictonaryKeys.h"


@interface GXQuestList()

@property (nonatomic,weak) id<GXQuestListDelegate> delegate;
@property (nonatomic,strong) NSArray *questListArray;
@property (nonatomic,strong) NSArray *joinedQuestList;
@property (nonatomic) NSUInteger typeIndex;

@end


@implementation GXQuestList

+ (GXQuestList *)sharedInstance
{
    static GXQuestList *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        
        sharedInstance = [[GXQuestList alloc] initSharedInstance];
    });
    
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

- (instancetype)initWithDelegate:(id<GXQuestListDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _questListArray = @[];
        _joinedQuestList = @[];
        _loading = NO;
    }
    
    return self;
}

//クエストの数を返す
- (NSUInteger)count
{
    return _questListArray.count;
}

- (NSUInteger)joinedQuestCount
{
    return _joinedQuestList.count;
}

//クエストの要素を取得
- (GXQuest *)questAtIndex:(NSUInteger)index
{
    return _questListArray[index];
}

- (GXQuest *)joinedQuestAtIndex:(NSUInteger)index
{
    return _joinedQuestList[index];
}


//通信
- (void)requestAsyncronous:(NSUInteger)typeIndex
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    _loading =YES;
    _typeIndex = typeIndex;
    [self performSelector:@selector(requestAsyncronousDone) withObject:self afterDelay:1.0];
}

#pragma makr - Internal
-  (void)requestAsyncronousDone
{
    switch (_typeIndex) {
        case 0: //new quest
            [self handlerNewQuest];
            break;
            
        case 1:
            [self handlerJoinedQuest];
            break;
            
        case 2:
            [self handlerInvitedQuest];
            break;
            
        default:
            break;
    }
}

//みんなで共有しているクエストボードバケットから取得
- (void)handlerNewQuest
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    KiiBucket *bucket = [Kii bucketWithName:@"quest_board"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByDesc:@"_created"];
    
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            CWStatusBarNotification *notis = [CWStatusBarNotification new];
            notis.notificationLabelBackgroundColor = [UIColor redColor];
            [notis displayNotificationWithMessage:@"通信エラー" forDuration:2.0f];
            [_delegate questListDidLoad];
            _loading = NO;
        } else {
            _questListArray = @[];
            [self addQuest:results];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
}

//自分の受注済みのクエストバケットから取得
- (void)handlerJoinedQuest
{
    KiiBucket *bucket = [GXBucketManager sharedManager].joinedQuest;
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByDesc:@"_created"];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            CWStatusBarNotification *notis = [CWStatusBarNotification new];
            notis.notificationLabelBackgroundColor = [UIColor redColor];
            [notis displayNotificationWithMessage:@"通信エラー" forDuration:2.0f];
            [_delegate questListDidLoad];
            _loading = NO;

        } else {
            _joinedQuestList = @[];
            [self addQuest:results];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
}

//これはいらないかも
- (void)handlerInvitedQuest
{
    KiiBucket *bucket = [GXBucketManager sharedManager].inviteBoard;
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByDesc:@"_created"];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            CWStatusBarNotification *notis = [CWStatusBarNotification new];
            notis.notificationLabelBackgroundColor = [UIColor redColor];
            [notis displayNotificationWithMessage:@"通信エラー" forDuration:2.0f];
            [_delegate questListDidLoad];
            _loading = NO;

        } else {
            _questListArray = @[];
            [self addQuest:results];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
}

//取得したクエストで更新
- (void)addQuest:(NSArray *)results
{
    NSMutableArray *newQuestArray = [NSMutableArray arrayWithArray:_questListArray];
    
    for (KiiObject *obj in results) {
        NSString *title = [obj getObjectForKey:quest_title];
        NSString *fbid = [obj getObjectForKey:quest_createdUser_fbid];
        NSString *questID = obj.objectURI;
        NSString *questReq = [obj getObjectForKey:quest_requirement];
        NSString *questDes = [obj getObjectForKey:quest_description];
        NSNumber *playerNum = [obj getObjectForKey:quest_player_num];
        NSString *createdUserName = [obj getObjectForKey:quest_owner];
        NSDate *date = obj.created; //utc
        if (createdUserName == nil) {
            createdUserName = @"BeaconGalax";
        }
        NSString *groupURI = [obj getObjectForKey:quest_groupURI];
        
        
        KiiBucket *bucket = obj.bucket;
        GXQuest *quest = [[GXQuest alloc] initWithTitle:title fbID:fbid];
        quest.quest_id = questID;
        quest.bucket = bucket;
        quest.quest_req = questReq;
        quest.quest_des = questDes;
        quest.player_num = playerNum;
        quest.createdUserName = createdUserName;
        quest.createdDate = date;
        quest.groupURI = groupURI;
        [newQuestArray addObject:quest];
    }
    
    if (self.typeIndex == 0) {
        _questListArray = newQuestArray;
    } else if (self.typeIndex == 1) {
        _joinedQuestList = newQuestArray;
    }

}

@end
