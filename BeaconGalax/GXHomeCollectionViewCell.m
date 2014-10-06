//
//  GXHomeCollectionViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/05.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXHomeCollectionViewCell.h"
#import "GXNotification.h"

@implementation GXHomeCollectionViewCell



- (IBAction)joinAction:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"確認" message:@"このクエストに参加しますか" delegate:self cancelButtonTitle:@"やめる" otherButtonTitles:@"参加", nil];
    
    [alert show];
}

#pragma mark AlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
            
        case 1:
            NSLog(@"^--->");
            [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestJoinNotification object:self];
            break;
            
        default:
            break;
    }
}
@end
