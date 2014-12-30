//
//  GXQuestList.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>

@class GXQuest;
//Delegate
@protocol GXQuestListDelegate <NSObject>

- (void)questListDidLoad;

@end

@interface GXQuestList : NSObject

@property (nonatomic) BOOL loading;

+ (GXQuestList *)sharedInstance;
- (instancetype)initWithDelegate:(id<GXQuestListDelegate>)delegate;
- (NSUInteger)count;
- (NSUInteger)joinedQuestCount;

- (GXQuest *)questAtIndex:(NSUInteger)index;
- (GXQuest *)joinedQuestAtIndex:(NSUInteger)index;

//通信
- (void)requestAsyncronous:(NSUInteger)typeIndex;



@end
