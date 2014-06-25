//
//  GXBeaconTableViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXBeaconTableViewController.h"
#import "GXBeacon.h"
#import "GXBeaconRegion.h"
#import <CSAnimationView.h>
#import "GXCustomCell.h"
#import "GXTableViewConst.h"
#import "GXCustomSectionHeader.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXBeaconTableViewController ()

@property GXBeacon *beacon;
@property (weak, nonatomic) IBOutlet UIButton *monitoringButton;
@property GXBeaconMonitoringStatus monitoringStatus;
- (IBAction)monitoringButtonPushed:(id)sender;

@end

@implementation GXBeaconTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

#pragma mark - Viewライフサイクル

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.beaconTable.delegate = self;
    self.beaconTable.dataSource = self;
    
    self.beacon = [GXBeacon sharedManager];
    self.beacon.delegate = self;
    
    
    //一回だけ実行
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        GXBeaconRegion *region;
        
        region = [self.beacon registerRegion:kBeaconUUID identifier:kIdentifier];
        if (region) {
            region.rangingEnabled = YES;
            
            //ノーティフィケーション用のフラグ設定をやるっぽい
        }

    });

    
    //カスタムcellを登録
    UINib *nib = [UINib nibWithNibName:TableViewCustomCellIdentifier bundle:nil];
    [self.beaconTable registerNib:nib forCellReuseIdentifier:@"cell"];
    
    UINib *secHeadernib = [UINib nibWithNibName:TableViewCustomSectionHeaderIdentifier bundle:nil];
    [self.beaconTable registerNib:secHeadernib forCellReuseIdentifier:@"sectionHeader"];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.beaconTable reloadData];
    [self.beacon startMonitoring];
    
    [self.view startCanvasAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"section num : %d",self.beacon.regions.count);
    return [self.beacon.regions count];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    GXBeaconRegion *region = [self.beacon.regions objectAtIndex:section];
    
    
    if (region) {
        if (region.beacons == nil) {
            return 0;
        } else {
            
            return region.beacons.count;
        }
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    GXCustomCell *cell = [self.beaconTable dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[GXCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GXCustomCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GXBeaconRegion *region = self.beacon.regions[indexPath.section];
    
    if (region && region.beacons) {
        CLBeacon *beacon = region.beacons[indexPath.row];
        
        cell.majorLable.text = [NSString stringWithFormat:@"major:%@",beacon.major];
        cell.minorLabel.text = [NSString stringWithFormat:@"minor:%@",beacon.minor];
        cell.rssiLabel.text = [NSString stringWithFormat:@"rssi:%ld",(long)beacon.rssi];
        cell.accLabel.text = [NSString stringWithFormat:@"acc:%lf",beacon.accuracy];
        
        switch (beacon.proximity) {
            case CLProximityFar:
                cell.proxLabel.text = @"prox:Far";
                break;
            case CLProximityUnknown:
                cell.proxLabel.text = @"prox:Unknown";
                break;
            case CLProximityNear:
                cell.proxLabel.text = @"prox:Near";
                break;
            case CLProximityImmediate:
                cell.proxLabel.text = @"prox:Immediate";
                
            default:
                break;
        }
    }
    
}

#pragma mark - TalbeViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    GXCustomSectionHeader *headerCell = [self.beaconTable dequeueReusableCellWithIdentifier:@"sectionHeader"];
    
    GXBeaconRegion *region = self.beacon.regions[section];
    
    headerCell.identifierLabel.text = region.identifier;
    
    return headerCell;


    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70;
}

#pragma mark - GXBeacon Delegate
- (void)didRangeBeacons:(GXBeaconRegion *)region
{
    if (!region.beacons) {
        NSLog(@"didRangeBeacon:count 0");
    } else {
        
    }
    
    [self.beaconTable reloadData];
    
}

- (void)didUpdatePeripheralState:(NSString *)state
{
    NSMutableString *bluetoothLabelText = [NSMutableString stringWithFormat:@"Bluetooh:"];
    [bluetoothLabelText appendString:state];
    self.bluetoothLabel.text = bluetoothLabelText;

}

- (void)didUpdateLocationStatus:(NSString *)status
{
    NSMutableString *locationLabelText = [NSMutableString stringWithFormat:@"location:"];
    [locationLabelText appendString:status];
    self.AuthLabel.text = locationLabelText;
}

- (void)didUpdateMonitoringStatus:(GXBeaconMonitoringStatus)status
{
    self.monitoringStatus = status;
    
    switch (status) {
        case kGXBeaconMonitoringStatusDisabled:
            self.monitoringButton.enabled = NO;
            [self.monitoringButton setTitle:@"Disable" forState:UIControlStateNormal];
            break;
            
        case kGXBeaconMonitoringStatusMonitoring:
            self.monitoringButton.enabled = YES;
            [self.monitoringButton setTitle:@"Monitoring(press to off)" forState:UIControlStateNormal];
            break;
        case kGXBeaconMonitoringStatusStopped:
            self.monitoringButton.enabled = YES;
            [self.monitoringButton setTitle:@"Stopped(press to on)" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    
}

#pragma mark - Buttonアクション -

- (IBAction)monitoringButtonPushed:(id)sender {
    
    if (self.monitoringStatus == kGXBeaconMonitoringStatusStopped) {
        [self.beacon startMonitoring];
    }
    if (self.monitoringStatus == kGXBeaconMonitoringStatusMonitoring) {
        [self.beacon stopMonitoring];
    }
}

@end
