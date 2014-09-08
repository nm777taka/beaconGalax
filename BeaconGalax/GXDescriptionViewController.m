//
//  GXDescriptionViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/08.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXDescriptionViewController.h"
#import "GXDescriptionTableViewCell.h"
#import "GXParticipantsCell.h"
#import "GXDictonaryKeys.h"

@interface GXDescriptionViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *selectQuestArray;
@property NSMutableArray *participantsArray;
@property GXDescriptionTableViewCell *stubDesctiptionCell;
@property GXParticipantsCell *stubParticipantsCell;
@end

@implementation GXDescriptionViewController

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
    _selectQuestArray = [NSMutableArray new];
    _participantsArray = [NSMutableArray new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    //セパレータを左端まで伸ばす
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    _stubDesctiptionCell = [_tableView dequeueReusableCellWithIdentifier:@"DescriptionCell"];

    _stubParticipantsCell = [_tableView dequeueReusableCellWithIdentifier:@"ParticipantsCell"];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
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

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 1;
    else return 1;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    
    switch (section){
            case 0:
            sectionName = @"Quest";
            break;
        
            case 1:
            sectionName = @"参加者";
            break;
    }
    
    return sectionName;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        GXDescriptionTableViewCell *desCell = [_tableView dequeueReusableCellWithIdentifier:@"DescriptionCell" forIndexPath:indexPath];
        
        [self configureDescriptionCell:desCell atIndexPath:indexPath];
        
        return desCell;
    } else {
        GXParticipantsCell *participantsCell = [_tableView dequeueReusableCellWithIdentifier:@"ParticipantsCell" forIndexPath:indexPath];
        
        [self configureParticipantsCell:participantsCell atIndexPath:indexPath];
        
        return participantsCell;
    }
}

- (void)configureDescriptionCell:(GXDescriptionTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.userIcon.profileID = [_object getObjectForKey:quest_createdUser_fbid];
    cell.userNameLabel.text = [_object getObjectForKey:quest_createdUserName];
    cell.mainLabel.text = [_object getObjectForKey:quest_title];
    
    NSDateFormatter *dateformatetr = [[NSDateFormatter alloc]init];
    dateformatetr.dateFormat = @"yyyy/MM/dd HH:mm";
    NSString *dateText = [dateformatetr stringFromDate:_object.created];
    cell.subLabel.text = dateText;
    
    
}

- (void)configureParticipantsCell:(GXParticipantsCell *)cell atIndexPath:(NSIndexPath *)indexPath

{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        [self configureDescriptionCell:_stubDesctiptionCell atIndexPath:indexPath];
        [_stubDesctiptionCell layoutSubviews];
        CGFloat height = [_stubDesctiptionCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        return height + 1;
        
    } else {
        
//        [self configureParticipantsCell:_stubParticipantsCell atIndexPath:indexPath];
//        [_stubParticipantsCell layoutSubviews];
//        CGFloat height = [_stubParticipantsCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//        return height+1;
        
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return 40.0;
    else return 50.0;
}

@end
