//
//  GXCollectionViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCollectionViewCell.h"
#import "FUIButton+GXTheme.h"
#import <FlatUIKit/FlatUIKit.h>

@implementation GXCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        

        
    }
    return self;
}

#pragma mark - UI
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.questNameLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.fbIConView.layer setCornerRadius:25.f];
    
}


- (IBAction)joinButton:(id)sender {
    
    //クエストに参加する
    
    
}
@end
