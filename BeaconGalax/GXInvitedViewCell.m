
//
//  GXInvitedViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXInvitedViewCell.h"
#import "GXNotification.h"

@implementation GXInvitedViewCell

- (IBAction)joinAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"inviteViewCellTopped" object:self];
}

@end
