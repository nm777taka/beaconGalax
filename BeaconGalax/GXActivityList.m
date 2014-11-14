//
//  GXActivityList.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXActivityList.h"
#import "GXActivity.h"

@interface GXActivityList()

@property (nonatomic,weak) id<GXActivityListDelegate> delegate;
@property (nonatomic,strong) NSArray *activityArray;

@end

@implementation GXActivityList

- (instancetype)initWithDelegate:(id<GXActivityListDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _activityArray = @[];
    }
    
    return self;
}

- (NSUInteger)count
{
    return self.activityArray.count;
}

- (void)addActivity
{
    NSMutableArray *newActivity = [NSMutableArray arrayWithArray:_activityArray];
    for (int i = 0; i < 20; i++) {
        [newActivity addObject:[[GXActivity alloc] init]];
    }
    _activityArray = newActivity;
}

- (GXActivity *)activityAtIndex:(NSUInteger)index
{
    return _activityArray[index];
}

- (void)requestAsynchronous
{
    [self performSelector:@selector(requestAsynchronousDone) withObject:self afterDelay:1.0];
}

- (void)requestAsynchronousDone
{
    [self addActivity];
    [_delegate activityListDidLoad];
}

@end
