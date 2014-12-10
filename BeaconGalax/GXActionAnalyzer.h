//
//  GXActionAnalyzer.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXActionAnalyzer : NSObject

+ (GXActionAnalyzer *)sharedInstance;

//各アクションを記録
//クエスト関連
- (void)setActionName:(NSString *)actionName;

@end
