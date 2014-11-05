//
//  GXClearViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXClearViewController.h"
#import "GXBucketManager.h"
#import "GXExeQuestManager.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXQuestViewController.h"
#import "GXInviteQuestViewController.h"
#import "GXFrostedViewController.h"

@interface GXClearViewController ()


@end

@implementation GXClearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"point:%d",self.point);
    [self registerPoint];
    
    [NSTimer bk_scheduledTimerWithTimeInterval:3.0 block:^(NSTimer *timer) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Congratulation" message:@"クエストクリアおめでとうございます" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self clearQuest];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            UIViewController *initViewController = [storyboard instantiateInitialViewController];
            [self presentViewController:initViewController animated:NO completion:nil];
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];

    } repeats:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearQuest
{
    [[GXExeQuestManager sharedManager] clearNowExeQuest];
}

- (void)registerPoint
{
    NSError *error;
    KiiBucket *pointBucket = [[KiiUser currentUser] bucketWithName:@"point"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    KiiQuery *nxQuery;
    NSArray *results = [pointBucket executeQuerySynchronous:query withError:&error andNext:&nxQuery];
    if (results.count == 0) {
        KiiObject *pointObj = [pointBucket createObject];
        [pointObj setObject:[NSNumber numberWithInt:self.point] forKey:@"point"];
        [pointObj saveSynchronous:&error];
    } else {
        KiiObject *currentPointObj = results.firstObject;
        [currentPointObj refreshSynchronous:&error];
        int currPoint = [[currentPointObj getObjectForKey:@"point"] intValue];
        currPoint += self.point;
        [currentPointObj setObject:[NSNumber numberWithInt:currPoint] forKey:@"point"];
        [currentPointObj saveSynchronous:&error];
    }
}


@end
