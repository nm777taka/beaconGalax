//
//  GXActionViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/08/06.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXActionViewController.h"

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
@end
