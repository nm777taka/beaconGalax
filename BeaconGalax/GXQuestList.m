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
@property (nonatomic,strong) NSArray *dailyQuestList;
@property (nonatomic,strong) NSArray *invitingQuestList;
@property (nonatomic) NSUInteger typeIndex;

@end


static int const QuestType_New = 0;
static int const QuestType_Joined = 1;
static int const QuestType_Daily = 2;
static int const QuestType_Inviting = 3;

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
        _dailyQuestList = @[];
        _invitingQuestList = @[];
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

- (NSUInteger)dailyQuestCount
{
    return _dailyQuestList.count;
}

- (NSUInteger)invitingQuestCount
{
    return _invitingQuestList.count;
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

- (GXQuest *)dailyQuestAtIndex:(NSUInteger)index
{
    return _dailyQuestList[index];
}

- (GXQuest *)invitingQuestAtIndex:(NSUInteger)index
{
    return _invitingQuestList[index];
}

//通信
- (void)requestAsyncronous:(NSUInteger)typeIndex
{
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
            [self handlerDailyQuest];
            break;
            
        case 1:
            [self handlerJoinedQuest];
            [self handlerInvitingQuest];
            break;
            
        case 2: //
            break;
            
        default:
            break;
    }
}

//みんなで共有しているクエストボードバケットから取得
- (void)handlerNewQuest
{
    KiiBucket *bucket = [Kii bucketWithName:@"quest_board"];
    KiiClause *clause = [KiiClause equals:@"type" value:@"user"];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
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
            [self addQuest:results questType:QuestType_New];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
}

//自分の受注済みのクエストバケットから取得
- (void)handlerJoinedQuest
{
    KiiBucket *bucket = [[KiiUser currentUser] bucketWithName:@"joined_quest"];
    KiiClause *clause = [KiiClause equals:quest_isCompleted value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
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
            [self addQuest:results questType:QuestType_Joined];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
}

- (void)handlerDailyQuest
{
    KiiBucket *bucket = [[KiiUser currentUser] bucketWithName:@"notJoined_quest"];
    KiiClause *clause = [KiiClause equals:@"type" value:@"system"];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            _loading = NO;
        } else {
            _dailyQuestList = @[];
            [self addQuest:results questType:QuestType_Daily];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
    
}

- (void)handlerInvitingQuest
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    KiiBucket *bucket = [GXBucketManager sharedManager].questBoard;
    KiiClause *clause1 = [KiiClause equals:quest_isCompleted value:@NO];
    KiiClause *clause2 = [KiiClause equals:quest_owner value:[KiiUser currentUser].displayName];
    NSArray *totalClauseArray = @[clause1,clause2];
    KiiClause *totalClause = [KiiClause andClauses:totalClauseArray];
    KiiQuery *query = [KiiQuery queryWithClause:totalClause];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            _loading = NO;
        } else {
            _invitingQuestList = @[];
            [self addQuest:results questType:QuestType_Inviting];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
}

//internal
//取得したクエストで更新
- (void)addQuest:(NSArray *)results questType:(NSInteger)questType
{
    NSMutableArray *questArray;
    if (questType == QuestType_New ) {
        questArray = [NSMutableArray arrayWithArray:_questListArray];
    } else if (questType == QuestType_Joined) {
        questArray = [NSMutableArray arrayWithArray:_joinedQuestList];
    } else if (questType == QuestType_Daily) {
        questArray = [NSMutableArray arrayWithArray:_dailyQuestList];
    } else if (questType == QuestType_Inviting) {
        questArray = [NSMutableArray arrayWithArray:_invitingQuestList];
    }
    
    for (KiiObject *obj in results) {
        
        NSString *title = [obj getObjectForKey:quest_title];
        //NSString *fbid = [obj getObjectForKey:quest_createdUser_fbid];
        NSString *fbid = [obj getObjectForKey:quest_owner_fbid];
        NSString *questID;
        if ([obj getObjectForKey:@"questID"]) {
            questID = [obj getObjectForKey:@"questID"];
        } else {
            questID = obj.objectURI;
        }
        
        NSString *questReq = [obj getObjectForKey:quest_requirement];
        NSString *questDes = [obj getObjectForKey:quest_description];
        NSNumber *playerNum = [obj getObjectForKey:quest_player_num];
        NSString *createdUserName = [obj getObjectForKey:quest_owner];
        NSString *type = [obj getObjectForKey:@"type"];
        BOOL isStarted = [[obj getObjectForKey:quest_isStarted] boolValue];
        BOOL isCompleted = [[obj getObjectForKey:quest_isCompleted] boolValue];
        NSString *startDateString = [obj getObjectForKey:@"start_date"];
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
        quest.type = type;
        quest.isStarted = isStarted;
        quest.isCompleted = isCompleted;
        quest.startDateString = startDateString;
        [questArray addObject:quest];
    }
    
    if (questType == QuestType_New) {
        _questListArray = questArray;
    } else if (questType == QuestType_Joined) {
        _joinedQuestList = questArray;
    } else if (questType == QuestType_Daily) {
        _dailyQuestList = questArray;
    } else if (questType == QuestType_Inviting) {
        _invitingQuestList = questArray;
    }

}

@end
