//
//  GXQuestExeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestExeViewController.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"

@interface GXQuestExeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel *participantLabel;

@property NSString *ownerName;
@property NSString *ownerFBID;
@property NSString *title;
@property NSNumber *isStarted;
@property NSNumber *isCompleted;
@property KiiGroup *questGroupURI;

@end

@implementation GXQuestExeViewController


#pragma mark ViewLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self parseObject:self.exeQuest];
}

- (void)parseObject:(KiiObject *)object
{
    self.title = [object getObjectForKey:quest_title];
    self.ownerName = [object getObjectForKey:quest_createdUserName];
    self.ownerFBID = [object getObjectForKey:quest_createdUser_fbid];
    self.questGroupURI = [object getObjectForKey:quest_groupURI];
    self.isStarted = [object getObjectForKey:quest_isStarted];
    self.isCompleted = [object getObjectForKey:quest_isCompleted];
    
    NSLog(@"----->title:%@",self.title);
    
}

- (void)configureLabel
{
    self.ownerLabel.text = self.ownerName;
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
- (IBAction)goback:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
