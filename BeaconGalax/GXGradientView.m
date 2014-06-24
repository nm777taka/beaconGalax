//
//  GXGradientView.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXGradientView.h"
#import "UIColor+GXtheme.h"

#define START_COLOR RGB(81,146,187)
#define END_COLOR RGB(143,201,213)

@implementation GXGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self gradientLayer];
    }
    
    return self;
}

- (void)gradientLayer
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor gxGradientStartColor].CGColor,
                       (id)[UIColor gxGradientEndColor].CGColor,nil];
    [gradient setStartPoint:CGPointMake(0.5, 0.5)];
    [gradient setEndPoint:CGPointMake(0.5, 1.0)];
    [self.layer insertSublayer:gradient atIndex:0];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
