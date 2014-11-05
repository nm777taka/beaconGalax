//
//  GXQuestCompleteViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/18.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestCompleteViewController.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"

@interface GXQuestCompleteViewController ()
@property (weak, nonatomic) IBOutlet FUIButton *clearButton;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation GXQuestCompleteViewController{
}

- (void)viewDidLoad {
   
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
