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
#import "GXNotification.h"

typedef NS_ENUM(NSUInteger, kQuestType){
    NONE,
    kEat
};

@interface GXActionViewController ()
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView;
- (IBAction)closeButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property FUIButton *createButton;

@property kQuestType questType;

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
    [FUIButton gxQuestTheme:b1 withName:@"お腹すいた..."];
    
    [b1 bk_addEventHandler:^(id sender) {
        
        self.questType = kEat;
        [self configureParts];
        
    } forControlEvents:UIControlEventTouchUpInside];
   
    [self.animationView addSubview:b1];
   
    self.createButton = [[FUIButton alloc] initWithFrame:CGRectMake(self.animationView.frame.size.width/2.0f - 50, self.animationView.frame.size.height - 50, 100, 30)];
    [FUIButton gxQuestTheme:self.createButton withName:@"OK"];
    [self.createButton addTarget:self action:@selector(questCreate) forControlEvents:UIControlEventTouchUpInside];
    [self.animationView addSubview:self.createButton];
    //最初は消しとく
    self.createButton.alpha = 0.0f;
    
    self.label.font = [UIFont boldFlatFontOfSize:14];
    self.label.textColor = [UIColor blackColor];
    self.label.alpha = 0.0f;
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questCreated:) name:GXQuestCreatedNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.animationView.type = CSAnimationTypeBounceUp;
    [self.view startCanvasAnimation];
    
    self.questType = NONE;
    self.createButton.alpha  = 0.0f;
    self.label.alpha = 0.0f;
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

- (IBAction)closeButtonAction:(id)sender
{
    [self closeView];
}


#pragma mark ButtonAction
- (void)questCreate
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
        NSString *questTitle;
        NSString *questDescription;
        
        switch (self.questType) {
            case kEat:
                questTitle = @"ご飯いこう";
                questDescription = [NSString stringWithFormat:@"%@がご飯にいこうと言っています",userName];
                break;
                
            default:
                break;
        }
        
        quest.title = questTitle;
        quest.description = questDescription;
        quest.createUserURI = current_userObject.objectURI;
        quest.fb_id = [current_userObject getObjectForKey:@"facebook_id"];
        quest.isCompleted = [NSNumber numberWithBool:NO];
        [[GXBucketManager sharedManager ] registerQuest:quest];
        [self closeView];
        
    } else {
        NSLog(@"ユーザを取得できませんでした");
    }
    
}

- (void)configureParts
{
    [UIView animateKeyframesWithDuration:0.5f delay:0 options:0 animations:^{
        self.createButton.alpha = 1.0;
        self.label.alpha = 1.0;
    } completion:nil];
}

- (void)closeView
{
    [self.view removeFromSuperview];
}


#pragma mark - Notification
- (void)questCreated:(NSNotification *)notification
{
    //クエスト作成された
    NSLog(@"クエスト作成");
}
@end
