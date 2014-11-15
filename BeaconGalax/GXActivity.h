//
//  GXActivity.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXActivity : NSObject

- (instancetype)initWithName:(NSString *)name text:(NSString *)text iconID:(NSString *)iconID dateText:(NSString *)dateText;

//表示する要素
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *msg;
@property (nonatomic,retain) NSString *fbID;
@property (nonatomic,retain) NSString *dateText;

@end
