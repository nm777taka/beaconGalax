//
//  GXQuest.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXQuest : NSObject

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *createUserURI;
@property (nonatomic,retain) NSString *fb_id;
@property (nonatomic,retain) NSString *group_uri;
@property (nonatomic,assign) NSNumber *isStarted;
@property (nonatomic,assign) NSNumber *isCompleted;


@end
