//
//  GXQuestCreateViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestCreateViewController.h"
#import "UIPlaceHolderTextView.h"
#import "GXBucketManager.h"
#import "GXQuest.h"
#import "FUIAlertView+GXAlertView.h"
#import "GXNotification.h"
@interface GXQuestCreateViewController ()


@end

@implementation GXQuestCreateViewController

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
    
    //textViewの設定
    self.descriptionTextView.placeholder = @"タイトルを入力してください";
    self.descriptionTextView.placeholderColor = [UIColor grayColor];
    self.descriptionTextView.backgroundColor = [UIColor cloudsColor];
    self.descriptionTextView.textColor  = [UIColor midnightBlueColor];
    [self.descriptionTextView setContentInset:UIEdgeInsetsMake(-50, 0, 50, 0)];
    
    //キーボードのサイズ変更
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self configurenavigationBar];
    
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(questCreated:) name:GXQuestCreatedNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.titleLabel becomeFirstResponder];
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

- (void)configurenavigationBar
{
    self.navigationController.navigationBar.barTintColor = [[UIColor turquoiseColor] colorWithAlphaComponent:1];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor cloudsColor]};
    
    UINavigationItem *navItem = [self.navigationController.navigationBar.items objectAtIndex:0];
    
    UIButton *leftNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
    leftNavButton.contentMode = UIViewContentModeScaleToFill;
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"Common_ButtonNavigationClose@2x.png"] forState:UIControlStateNormal];
    [leftNavButton bk_addEventHandler:^(id sender) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    UIButton *rightNavButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 38, 38)];
    rightNavButton.contentMode = UIViewContentModeScaleToFill;
    navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    [rightNavButton setBackgroundImage:[UIImage imageNamed:@"Common_ButtonNavigationDone@2x.png"] forState:UIControlStateNormal];
    [rightNavButton bk_addEventHandler:^(id sender) {
        //クエストをバケットに登録
        
        //バリデーション
        if (self.titleLabel.text.length == 0) {
            //アラート
            FUIAlertView *alert = [[FUIAlertView alloc] initWithTitle:@"test" message:@"test" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            alert = [FUIAlertView gxLoginTheme:alert];
            [alert show];
            
            
        } else {
            GXQuest *quest = [GXQuest new];
            quest.title = self.titleLabel.text;
            quest.description = self.descriptionTextView.text;
            quest.isCompleted = [NSNumber numberWithBool:NO];
            [[GXBucketManager sharedManager] registerQuest:quest];
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
}

#pragma mark - TextView delegate
- (void)keyboardChanged:(NSNotification *)notification
{
   //キーボードのフレームを取得
    NSDictionary *info = [notification userInfo];
    NSValue *keyValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [keyValue CGRectValue].size;
    
    //ツールバーなどのviewを動かす
}

#pragma mark - FUIAlertViewDelegate

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

#pragma makr - GXNotification
- (void)questCreated:(GXNotification *)notification
{
    NSLog(@"クエスト作成成功");
    //アラート
}
@end
