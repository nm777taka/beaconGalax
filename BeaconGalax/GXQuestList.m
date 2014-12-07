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

@property (nonatomic,strong) NSArray *notJoinQuestList;
@property (nonatomic,strong) NSArray *joinedQuestList;
@property (nonatomic,strong) NSArray *inviteQuestList;
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
        _notJoinQuestList = @[];
        _joinedQuestList = @[];
        _inviteQuestList = @[];
        _loading = NO;
    }
    
    return self;
}

- (NSUInteger)count
{
    return _questListArray.count;
}

-(NSUInteger)notjoinQuestCount
{
    return _notJoinQuestList.count;
}

- (NSUInteger)joinedQuestCount
{
    return _joinedQuestList.count;
}

- (NSUInteger)inviteQuestCount
{
    return _inviteQuestList.count;
}

- (GXQuest *)questAtIndex:(NSUInteger)index
{
    return _questListArray[index];
}

- (GXQuest *)notjoinQuestAtIndex:(NSUInteger)index
{
    return _notJoinQuestList[index];
}

- (GXQuest *)joinedQuestAtIndex:(NSUInteger)index
{
    return _joinedQuestList[index];
}

- (GXQuest *)inviteQuestAtIndex:(NSUInteger)index
{
    return _inviteQuestList[index];
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

- (void)handlerNewQuest
{
    KiiBucket *bucket = [GXBucketManager sharedManager].notJoinedQuest;
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByDesc:@"_created"];
    
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            _questListArray = @[];
            [self addQuest:results];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
}

- (void)handlerJoinedQuest
{
    KiiBucket *bucket = [GXBucketManager sharedManager].joinedQuest;
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByDesc:@"_created"];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            _questListArray = @[];
            [self addQuest:results];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
}

- (void)handlerInvitedQuest
{
    KiiBucket *bucket = [GXBucketManager sharedManager].inviteBoard;
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByDesc:@"_created"];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            _questListArray = @[];
            [self addQuest:results];
            [_delegate questListDidLoad];
            _loading = NO;
        }
    }];
}

- (void)addQuest:(NSArray *)results
{
    NSMutableArray *newQuestArray = [NSMutableArray arrayWithArray:_questListArray];
    
    for (KiiObject *obj in results) {
        NSString *title = [obj getObjectForKey:quest_title];
        NSString *fbid = [obj getObjectForKey:quest_owner_fbid];
        NSString *questID = obj.objectURI;
        NSString *questReq = [obj getObjectForKey:quest_requirement];
        NSString *questDes = [obj getObjectForKey:quest_description];
        NSNumber *playerNum = [obj getObjectForKey:quest_player_num];
        NSString *createdUserName = [obj getObjectForKey:quest_owner];
        NSDate *date = obj.created;
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

    _questListArray = newQuestArray;
}

@end
