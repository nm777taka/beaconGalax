//
//  GXRestAPIViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXRestAPIViewController.h"

@interface GXRestAPIViewController ()
- (IBAction)getPageView:(id)sender;
- (IBAction)actionGet:(id)sender;

@end

@implementation GXRestAPIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([KiiUser loggedIn]) {
        NSLog(@"login");
    } else {
        NSLog(@"not login");
    }
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

//すべてのユーザのページビューを取得
- (IBAction)getPageView:(id)sender {
    //全ユーザを取得
    KiiBucket *bucket = [Kii bucketWithName:@"galax_user"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByAsc:@"point"];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        for (KiiObject* obj in results) {
            NSString *userID = [obj getObjectForKey:@"userID"];
            NSString *currentUserName = [obj getObjectForKey:@"name"];
            KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"getAllUserPageView"];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:userID,@"userID", nil];
            
            KiiServerCodeEntryArgument *arg = [KiiServerCodeEntryArgument argumentWithDictionary:dict];
            [entry execute:arg withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
                //各ユーザのpageViewデータ
                NSDictionary *retdict = [result returnedValue];
                NSLog(@"名前:%@",currentUserName);
                NSLog(@"%@",[retdict valueForKey:@"returnedValue"]);
            }];
        }
    }];
    
}

- (IBAction)actionGet:(id)sender {
    
    KiiBucket *bucket = [Kii bucketWithName:@"galax_user"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByAsc:@"point"];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        for (KiiObject* obj in results) {
            NSString *userID = [obj getObjectForKey:@"userID"];
            NSString *currentUserName = [obj getObjectForKey:@"name"];
            KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"getUserActionData"];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:userID,@"userID", nil];
            
            KiiServerCodeEntryArgument *arg = [KiiServerCodeEntryArgument argumentWithDictionary:dict];
            [entry execute:arg withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
                //各ユーザのpageViewデータ
                NSDictionary *retdict = [result returnedValue];
                NSLog(@"名前:%@",currentUserName);
                NSLog(@"%@",[retdict valueForKey:@"returnedValue"]);
            }];
        }
    }];

}
@end
