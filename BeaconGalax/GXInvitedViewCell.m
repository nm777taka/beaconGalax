
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

- (void)awakeFromNib
{
    self.ownerName.font = [UIFont boldFlatFontOfSize:15];
    
}

- (IBAction)joinAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"inviteViewCellTopped" object:self];
}

- (IBAction)showInfo:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"questInfo" object:self];
}
@end
