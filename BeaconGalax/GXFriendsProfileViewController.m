//
//  GXFriendsProfileViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXFriendsProfileViewController.h"
#import "GXFriendsProfileCell.h"
#import "GXTableViewConst.h"


@interface GXFriendsProfileViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentdControl;
@property (weak, nonatomic) IBOutlet UITableView *userListTableView;

@property NSMutableArray *onlineUserList;
@property NSMutableArray *offlineUserList;

@end

@implementation GXFriendsProfileViewController

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
    self.userListTableView.delegate = self;
    self.userListTableView.dataSource = self;
    
    self.onlineUserList = [NSMutableArray new];
    self.offlineUserList = [NSMutableArray new];
    
    UINib *nib = [UINib nibWithNibName:GXFriendsProfileCellIdentifier bundle:nil];
    [self.userListTableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    self.segmentdControl.selectedSegmentIndex = 0;
    [self.segmentdControl addTarget:self action:@selector(segmentedValueChanged:) forControlEvents:UIControlEventValueChanged];
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

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"Cell";
    
    GXFriendsProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GXFriendsProfileCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - SegmentedControl
- (void)segmentedValueChanged:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    switch (segment.selectedSegmentIndex) {
        case 0: //オンライン
            //DBからオンラインフラグをもつユーザをフェッチ
            break;
        case 1:
            //DBからオフラインフラグをもつユーザをフェッチ
            break;
            
        default:
            break;
    }
}

@end
