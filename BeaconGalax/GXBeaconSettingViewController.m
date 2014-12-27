//
//  GXBeaconSettingViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/18.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXBeaconSettingViewController.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldMargin = 10.0f;

const static CGFloat kJVFieldFontSize = 16.0f;

const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;


@interface GXBeaconSettingViewController ()
- (IBAction)closeView:(id)sender;
- (IBAction)settingDone:(id)sender;

@property JVFloatLabeledTextField *beaconMajorFiled;
@property BOOL isSetBeaconMajor;

@end

@implementation GXBeaconSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.beaconMajorFiled.keyboardType = UIKeyboardTypeNumberPad;
    
    CGFloat topOffset = 0;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self.view setTintColor:[UIColor blueColor]];
    
    topOffset = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
#endif
    
    UIColor *floatingLabelColor = [UIColor brownColor];
    self.beaconMajorFiled = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(kJVFieldMargin, topOffset, self.view.frame.size.width -2 * kJVFieldMargin, kJVFieldHeight)];
    self.beaconMajorFiled.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"major" attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    self.beaconMajorFiled.font = [UIFont fontWithName:@"Helvetica" size:kJVFieldFontSize];
    self.beaconMajorFiled.floatingLabelTextColor = floatingLabelColor;
    self.beaconMajorFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.beaconMajorFiled];
    
    UIView *div1 = [UIView new];
    div1.frame = CGRectMake(kJVFieldMargin, self.beaconMajorFiled.frame.origin.y + self.beaconMajorFiled.frame.size.height, self.view.frame.size.width - 2 * kJVFieldMargin, 1.0f);
    
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div1];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    KiiObject *gxuser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
    NSNumber *major = [gxuser getObjectForKey:@"major"];
    NSLog(@"setBeaconMajor:%d",[major intValue]);
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


- (IBAction)closeView:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//Appのbeaocn管理Bucketと自分の情報にbeaconを書き込む
- (IBAction)settingDone:(id)sender
{
    
    KiiBucket *userBeacons = [GXBucketManager sharedManager].user_beacons;
    KiiObject *gxUser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
    NSNumber *currentMajor = [gxUser getObjectForKey:@"user_major"];
    //すでに設定されていたらするー
    if (currentMajor) {
        //errror
        CWStatusBarNotification *notis = [CWStatusBarNotification new];
        notis.notificationLabelBackgroundColor = [UIColor alizarinColor];
        [notis displayNotificationWithMessage:@"既に設定されています" forDuration:2.0f];
        return ;
        
    }
    
    KiiObject *obj = [userBeacons createObject];
    NSString *name = [KiiUser currentUser].displayName;
    NSString *fbid = [gxUser getObjectForKey:user_fb_id];
    NSNumber *major = [NSNumber numberWithInt:[self.beaconMajorFiled.text intValue]]; //ここが変わるとやばい
    
    //バリデーション
    if ([major intValue] == 0) {
        CWStatusBarNotification *notis = [CWStatusBarNotification new];
        notis.notificationLabelBackgroundColor = [UIColor alizarinColor];
        [notis displayNotificationWithMessage:@"正しい値を設定してください" forDuration:2.0f];
        return ;
    }
   
    [obj setObject:major forKey:@"major"];
    [obj setObject:name forKey:@"name"];
    [obj setObject:fbid forKey:@"fbid"];
    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
                
            [gxUser setObject:major forKey:@"user_major"];
            [gxUser saveWithBlock:^(KiiObject *object, NSError *error) {
                if (error) {
                    NSLog(@"error:%@",error);
                } else {
                        CWStatusBarNotification *notis = [CWStatusBarNotification new];
                        notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
                        [notis displayNotificationWithMessage:@"Major値を設定しました" forDuration:2.0f];
                }
            }];
                
        }
    }];
        
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
