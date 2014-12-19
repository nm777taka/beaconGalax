//
//  UILabel+Ajastable.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/19.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "UILabel+Ajastable.h"

@implementation UILabel (Ajastable)

+ (float)ajastHeight:(NSString *)show_word label:(UILabel *)label
{
    CGFloat fontSize = label.font.pointSize;
    float labelWidth = label.bounds.size.width;
    float labelHeight = label.bounds.size.height;
    float labelX = label.frame.origin.x;
    float labelY = label.frame.origin.y;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CGSize size = CGSizeMake(labelWidth, labelHeight);
    CGRect totalRect = [show_word boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil];
    float fitSizeHeight = totalRect.size.height;
    return fitSizeHeight;
}

@end
