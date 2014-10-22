//
//  GXStatusViewQuestInfo.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/22.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXStatusViewQuestInfo.h"

@interface GXStatusViewQuestInfo ()

@end

@implementation GXStatusViewQuestInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)nextStoryboard:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"subStoryboard" bundle:nil];
    UIViewController *initialViewController = [storyboard instantiateInitialViewController];
    [self presentViewController:initialViewController animated:YES completion:nil];
}

@end
