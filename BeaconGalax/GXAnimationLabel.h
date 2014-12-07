//
//  GXAnimationLabel.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/07.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXAnimationLabel : UILabel

- (void)animationFrom:(float)fromValue to:(float)toValue withDuration:(NSTimeInterval)duration;

@end
