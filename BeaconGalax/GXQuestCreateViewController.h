//
//  GXQuestCreateViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h> 
#import <BlocksKit/BlocksKit+UIKit.h>
#import "UIPlaceHolderTextView.h"
@interface GXQuestCreateViewController : UIViewController<UITextViewDelegate,FUIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *descriptionTextView;

@end
