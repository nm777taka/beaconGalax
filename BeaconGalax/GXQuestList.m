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
        _loading = NO;
    }
    
    return self;
}

- (NSUInteger)count
{
    return _questListArray.count;
}

- (GXQuest *)questAtIndex:(NSUInteger)index
{
    return _questListArray[index];
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
    KiiClause *clause = [KiiClause equals:@"isCompleted" value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [query sortByAsc:@"_created"];
    
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
    [query sortByAsc:@"_created"];
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
    [query sortByAsc:@"_created"];
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
        NSString *quest_id = obj.objectURI;
        KiiBucket *bucket = obj.bucket;
        GXQuest *quest = [[GXQuest alloc] initWithTitle:title fbID:fbid];
        quest.quest_id = quest_id;
        quest.bucket = bucket;
        
        
        [newQuestArray addObject:quest];
    }
    
    _questListArray = newQuestArray;
}

@end
