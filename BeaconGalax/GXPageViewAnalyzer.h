//
//  GXPageViewAnalyzer.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXPageViewAnalyzer : NSObject

+ (GXPageViewAnalyzer *)shareInstance;

- (void)setPageView:(NSString *)viewControllerName;

@end
