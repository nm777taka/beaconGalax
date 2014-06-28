//
//  GXViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXViewController.h"
#import "GXKiiCloud.h"
#import <CSAnimationView.h>
#import <FlatUIKit/FlatUIKit.h>


@interface GXViewController ()

@property GXKiiCloud *kiiCloudManager;

@end

@implementation GXViewController

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    FUIButton *helpButton = [[FUIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 3, self.view.frame.size.height - 100, 100, 50)];
    
    helpButton.buttonColor = [UIColor turquoiseColor];
    helpButton.shadowColor = [UIColor greenSeaColor];
    helpButton.shadowHeight = 3.0f;
    helpButton.cornerRadius = 6.0f;
    helpButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [helpButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [helpButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [helpButton setTitle:@"HELP" forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(testSelector:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:helpButton];
    
    self.kiiCloudManager = [GXKiiCloud sharedManager];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view startCanvasAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.kiiCloudManager kiiCloudLogin];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Exit
- (IBAction)goBack:(UIStoryboardSegue *)sender
{
    
}

#pragma mark - Button Action
- (void)testSelector:(id)sender
{
    NSLog(@"touch");
}



@end
