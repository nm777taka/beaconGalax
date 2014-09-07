//
//  GXHomeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXHomeViewController.h"
#import "NSMutableArray+Extended.h"
#import "GXNotification.h"
#import "GXQuestBoardViewController.h"
#import "GTScrollViewController.h"
#import "GXHomeTableViewCell.h"
#import "GXHomeTableViewHeader.h"
#import "GXActionViewController.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"


#define PADDING_TOP_BUTTOM 15
#define PADDING_LEFT_RIGHT 10
#define CORNER_RADIUS 2
#define SHADOW_RADIUS 3
#define SHADOW_OPACITY 0.5


@interface GXHomeViewController ()

@end

@implementation GXHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchQuestHandler:) name:GXQuestFetchedQuestWithJoinedNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    
}

- (void)questFetch
{
    //自分のバケットから
    //参加しているクエストを取得
    if ([KiiUser loggedIn]) {
        

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)gotoQuestBoard:(id)sender {
}

#pragma  mark - ノーティフィケーション
- (void)fetchQuestHandler:(NSNotification *)info
{
    
}

@end
