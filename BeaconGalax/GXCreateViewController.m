//
//  GXCreateViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCreateViewController.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"

#import "GXDictonaryKeys.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldMargin = 10.0f;

const static CGFloat kJVFieldFontSize = 16.0f;

const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

@interface GXCreateViewController ()
- (IBAction)create:(id)sender;
- (IBAction)closeView:(id)sender;

@property JVFloatLabeledTextField *titleField;
@property JVFloatLabeledTextView *descriptionView;

@end

@implementation GXCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat topOffset = 0;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self.view setTintColor:[UIColor blueColor]];
    
    topOffset = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
#endif
    
    UIColor *floatingLabelColor = [UIColor brownColor];
    self.titleField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(kJVFieldMargin, topOffset, self.view.frame.size.width - 2 * kJVFieldMargin, kJVFieldHeight)];
    self.titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"クエスト名" attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    self.titleField.font = [UIFont systemFontOfSize:kJVFieldFloatingLabelFontSize];
    self.titleField.floatingLabelTextColor = floatingLabelColor;
    self.titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.titleField];
    
    UIView *div1 = [UIView new];
    div1.frame = CGRectMake(kJVFieldMargin, self.titleField.frame.origin.y + self.titleField.frame.size.height, self.view.frame.size.width - 2 * kJVFieldMargin, 1.0f);
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div1];
    
    self.descriptionView = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(kJVFieldMargin, div1.frame.origin.y + div1.frame.size.height, self.view.frame.size.width - 2 * kJVFieldMargin, kJVFieldHeight * 3)];
    self.descriptionView.placeholder = @"クエスト詳細";
    self.descriptionView.placeholderTextColor = [UIColor darkGrayColor];
    self.descriptionView.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.descriptionView.floatingLabelTextColor  =  floatingLabelColor;
    self.descriptionView.floatingLabel.font = [UIFont boldSystemFontOfSize:kJVFieldFontSize];
    [self.view addSubview:self.descriptionView];
    [self.titleField becomeFirstResponder];
    
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

- (IBAction)create:(id)sender {
    
    if (self.titleField.text.length == 0) {
        //アラート
        return;
    }
    
    KiiObject *newObj = [KiiObject new];
    [newObj setObject:self.titleField.text forKey:quest_title];
    [newObj setObject:self.descriptionView.text forKey:quest_description];
    [newObj setObject:@NO forKey:quest_isCompleted];
    [newObj setObject:@NO forKey:quest_isStarted];
    [newObj setObject:[NSNumber numberWithInt:2] forKey:quest_player_num];
    [newObj setObject:@"クリア条件：リーダーがクリアボタンを押す" forKey:@"requirement"];
    [newObj setObject:[NSNumber numberWithInt:100] forKey:quest_reward];
    [newObj setObject:[NSNumber numberWithInt:0] forKey:quest_success_cnt];
    
    //ユーザに紐付いたビーコン
    [newObj setObject:@"user" forKey:quest_type];
    [newObj setObject:[NSNumber numberWithInt:28319] forKey:@"major"]; //対象
    [[GXBucketManager sharedManager] registerInviteBoard:newObj];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end