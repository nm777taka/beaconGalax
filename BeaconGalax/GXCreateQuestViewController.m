//
//  GXCreateQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/08.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCreateQuestViewController.h"
#import "UIPlaceHolderTextView.h"
#import "GXQuest.h"
#import "GXDictonaryKeys.h"
#import "GXBucketManager.h"
#import "GXNotification.h"


@interface GXCreateQuestViewController ()
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *textView;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
- (IBAction)addQuest:(id)sender;
- (IBAction)closeView:(id)sender;

@end

@implementation GXCreateQuestViewController

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
    self.textView.placeholderColor = [UIColor grayColor];
    self.textView.placeholder = @"クエストの内容を入力してください";
    [self.textView setContentInset:UIEdgeInsetsMake(-50, 0, 50, 0)];
    
    //キーボードのサイズ変更通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questCreated:) name:GXQuestCreatedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questCreated:) name:GXQuestCreatedNotification object:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
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


#pragma mark Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)keyboardChanged:(NSNotification*)notification
{
    // キーボードのフレームを取得
    NSDictionary *info = [notification userInfo];
    NSValue *keyValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [keyValue CGRectValue].size;
	
    // 自分のViewの高さからキーボードとツールバーの高さを引く。(ツールバーのY軸位置)
    NSInteger toolbarY = self.view.frame.size.height - keyboardSize.height - 44;
    
	[UIView animateWithDuration:0.3f
					 animations:^{
						 // 最後にツールバーを移動
						 self.toolBarView.frame = CGRectMake(0, toolbarY, 320, 44);
						 
						 // Text View
						 NSInteger textViewHeight = toolbarY - self.textView.frame.origin.y;
						 self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, textViewHeight);
					 }];
}

//- (IBAction)addQuest:(id)sender {
//    
//    if ([self.textView.text length] == 0) {
//        
//        
//    } else {
//       
//        //基本的な情報
//        KiiObject *user = [[GXBucketManager sharedManager] getMeFromGalaxUserBucket];
//        NSString *fbID = [user getObjectForKey:user_fb_id];
//        NSString *userURI = [user getObjectForKey:@"uri"];
//        
//        //クエスト参加時のためのグループを作る
//        NSError *error = nil;
//        NSString *groupName = @"QuestGroup"; //同じグループ名があっても大丈夫っぽい（一意性は保証してない)
//        KiiGroup *group = [KiiGroup groupWithName:groupName];
//        [group saveSynchronous:&error];
//        if (error != nil) {
//            
//        }
//        NSString *groupUri = [group objectURI];
//        
//        
//        //クエスト作成
//        GXQuest *quest = [GXQuest new];
//        quest.title = self.textView.text;
//        quest.fb_id = fbID;
//        quest.createUserURI = userURI;
//        quest.isStarted = @NO;
//        quest.isCompleted = @NO;
//        quest.group_uri = groupUri;
//        quest.createdUserName = [user getObjectForKey:user_name];
//        
//        [[GXBucketManager sharedManager] registerQuest:quest];
//        
//        //このクエストへの参加者をいれるバケットを作成
//        
//        
//        
//    }
//    
//}

- (IBAction)closeView:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Notification
- (void)questCreated:(NSNotification *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
