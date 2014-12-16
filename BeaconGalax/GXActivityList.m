//
//  GXActivityList.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXActivityList.h"
#import "GXActivity.h"
#import "GXDictonaryKeys.h"
#import "GXBucketManager.h"


@interface GXActivityList()

@property (nonatomic,weak) id<GXActivityListDelegate> delegate;
@property (nonatomic,strong) NSArray *activityArray;

@end

@implementation GXActivityList

+ (GXActivityList *)sharedInstance
{
    static GXActivityList *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXActivityList alloc] initSharedSingleton];
    });
    
    return sharedSingleton;
}

- (id)initSharedSingleton
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

- (instancetype)initWithDelegate:(id<GXActivityListDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _activityArray = @[];
        _loading = NO;
    }
    
    return self;
}

- (NSUInteger)count
{
    return self.activityArray.count;
}

////ここでデータ取る
//- (void)addActivity
//{
//    NSMutableArray *newActivity = [NSMutableArray arrayWithArray:_activityArray];
//    for (int i = 0; i < 20; i++) {
//        [newActivity addObject:[[GXActivity alloc] init]];
//    }
//    _activityArray = newActivity;
//}

- (GXActivity *)activityAtIndex:(NSUInteger)index
{
    return _activityArray[index];
}

//取得
- (void)requestAsynchronous
{
    _loading = YES;
    [self performSelector:@selector(requestAsynchronousDone) withObject:self afterDelay:1.0];
}

- (void)requestMoreAsynchronous
{
    _loading = YES;
    [self performSelector:@selector(requestMoreAsynchronousDone) withObject:self afterDelay:1.0];
}

//クエストのアクティビティを設定
- (void)registerQuestActivity:(NSString *)name
                   title:(NSString *)text
                    fbid:(NSString *)fbid
{
    /*
    KiiBucket *bucket = [GXBucketManager sharedManager].activityBucket;
    KiiObject *newActivity = [bucket createObject];
    [newActivity setObject:name forKey:@"name"];
    [newActivity setObject:text forKey:@"text"];
    [newActivity setObject:fbid forKey:@"fbid"];
    [newActivity saveWithBlock:^(KiiObject *object, NSError *error) {
        if (error != nil) {
            NSLog(@"activity登録完了");
        }
    }];
     */
}

#pragma mark - internals

- (void)addQuestActivity:(NSArray *)results
{
    NSMutableArray *newActivity = [NSMutableArray arrayWithArray:_activityArray];
    
    for (KiiObject *obj in results) {
        NSString *name = [obj getObjectForKey:@"name"];
        NSString *text = [obj getObjectForKey:@"text"];
        NSString *fbid = [obj getObjectForKey:@"fbid"];
        NSDate *date = obj.created;
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateStyle = NSDateFormatterShortStyle;
        NSString *formattedDateString = [df stringFromDate:date];
        GXActivity *activity = [[GXActivity alloc] initWithName:name text:text iconID:fbid dateText:formattedDateString];
        
        [newActivity addObject:activity];
    }
    
    _activityArray = newActivity;
}

- (void)requestAsynchronousDone
{
    KiiBucket *bucket = [GXBucketManager sharedManager].activityBucket;
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query setLimit:10];
    [query sortByDesc:@"_created"];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            _activityArray = @[];
            [self addQuestActivity:results];
            [_delegate activityListDidLoad];
            _loading = NO;
        }
        
        if (nextQuery) {
            _nextQuery = nextQuery;
            NSLog(@"次の10件があるよ");
        }
    }];
}

- (void)requestMoreAsynchronousDone
{
    NSLog(@"call");
    KiiQuery *query = _nextQuery; //前回の続き
    KiiBucket *bucket = [GXBucketManager sharedManager].activityBucket;
    [query setLimit:10];
    [query sortByDesc:@"_created"];
    
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"--->%@",error);
        } else {
            [self addQuestActivity:results];
            [_delegate activityListDidLoad];
            _loading = NO;
        }
        
        if (nextQuery) {
            _nextQuery = nextQuery;
        } else {
            _nextQuery = nil;
        }
    }];

}

@end
