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

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldMargin = 10.0f;

const static CGFloat kJVFieldFontSize = 16.0f;

const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;


@interface GXBeaconSettingViewController ()
- (IBAction)closeView:(id)sender;
- (IBAction)settingDone:(id)sender;

@property JVFloatLabeledTextField *beaconMajorFiled;

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

- (IBAction)settingDone:(id)sender {
    
    KiiBucket *userBeacons = [GXBucketManager sharedManager].user_beacons;
    KiiObject *obj = [userBeacons createObject];
    NSString *name = [KiiUser currentUser].displayName;
    NSNumber *major = [NSNumber numberWithInt:[self.beaconMajorFiled.text intValue]];
    [obj setObject:major forKey:@"major"];
    [obj setObject:name forKey:@"name"];
    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            NSLog(@"設定完了");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
}
@end
