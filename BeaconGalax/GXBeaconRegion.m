//
//  GXBeaconRegion.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXBeaconRegion.h"

@implementation GXBeaconRegion

- (id)init
{
    self = [super init];
    if (self) {
        //init
    }
    
    return self;
}

- (void)clearFlags
{
    self.rangingEnabled = NO;
    self.isMonitoring = NO;
    self.hasEntered = NO;
    self.isRanging = NO;
    self.failCount = 0;
    self.beacons = nil;
}


@end
