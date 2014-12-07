//
//  GXAnimationLabel.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/07.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXAnimationLabel.h"
@interface GXAnimationLabel()
@property (nonatomic,assign) float startValue,endValue,rate,totaltime;
@property (nonatomic,assign) CFTimeInterval startTime;
@end

@implementation GXAnimationLabel

- (void)animationFrom:(float)fromValue to:(float)toValue withDuration:(NSTimeInterval)duration
{
    self.startValue = fromValue;
    self.endValue = toValue;
    self.totaltime = duration;
    
    self.text = [self getTextFromProgress:self.startValue];
    
    //CADisplayLinkの生成とcallback
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateValue:)];
    self.startTime = CACurrentMediaTime();
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateValue:(CADisplayLink *)link
{
    float dt = ([link timestamp] - self.startTime) / self.totaltime;
    if (dt >= 1.0f) {
        self.text = [self getTextFromProgress:self.endValue];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    
    int current = (int)(self.endValue - self.startValue) * dt + self.startValue;
    self.text = [self getTextFromProgress:current];
}

- (NSString *)getTextFromProgress:(int)progress
{
    
    return [NSString stringWithFormat:@"%d",progress];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
