//
//  GXActionViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/08/06.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXActionViewController.h"
#import "FUIButton+GXTheme.h"
#import "GXQuest.h"
#import "GXBucketManager.h"

@interface GXActionViewController ()
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView;
- (IBAction)closeButtonAction:(id)sender;

@end

@implementation GXActionViewController

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
    self.view.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.730];
    [self.animationView.layer setCornerRadius:10];
    
    //Buttonイニシャライズ
    FUIButton *b1 = [[FUIButton alloc] initWithFrame:CGRectMake(10, self.animationView.frame.origin.y + 10, 100, 30)];
    [FUIButton gxQuestTheme:b1 withName:@"ご飯"];
    [b1 addTarget:self action:@selector(questCreateForEat) forControlEvents:UIControlEventTouchUpInside];
    [self.animationView addSubview:b1];
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.animationView.type = CSAnimationTypeBounceUp;
    [self.view startCanvasAnimation];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonAction:(id)sender {
    
//    self.animationView.type = CSAnimationTypeFadeOut;
//    [self.view startCanvasAnimation];
//    
//    //アニメーションが終わった0.5秒後にviewを消す
//    //GCD
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [self.view removeFromSuperview];
//        self.animationView.type = CSAnimationTypeBounceUp;
//    });
    [self.view removeFromSuperview];
    
}


#pragma mark ButtonAction
- (void)questCreateForEat
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    KiiBucket *bucket = [GXBucketManager sharedManager].galaxUser;
    NSError *error = nil;
    KiiClause *clause = [KiiClause equals:@"uri" value:[KiiUser currentUser].objectURI];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    NSMutableArray *allResult = [NSMutableArray new];
    KiiQuery *nextQuery;
    
    NSArray *results = [bucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    
    KiiObject *current_userObject = results.firstObject;
    
    
    if (current_userObject) {
        NSString *userName = [current_userObject getObjectForKey:@"name"];
        GXQuest *quest = [GXQuest new];
        quest.title = @"一緒にご飯いこう";
        quest.description = [NSString stringWithFormat:@"%@がご飯にいこうと言っています",userName];
        quest.createUserURI = current_userObject.objectURI;
        quest.fb_id = [current_userObject getObjectForKey:@"facebook_id"];
        quest.isCompleted = [NSNumber numberWithBool:NO];
        [[GXBucketManager sharedManager ] registerQuest:quest];
    } else {
        NSLog(@"ユーザを取得できませんでした");
    }
    
}
@end
