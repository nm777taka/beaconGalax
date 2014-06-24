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

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXBeaconTableViewController ()

@property GXBeacon *beacon;

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
    self.beacon = [GXBeacon sharedManager];
    
    GXBeaconRegion *region;

    region = [self.beacon registerRegion:kBeaconUUID identifier:kIdentifier];
    if (region) {
        region.rangingEnabled = YES;
        
        //ノーティフィケーション用のフラグ設定をやるっぽい
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableHeaderCell"];
    GXBeaconRegion *region = self.beacon.regions[section];
    if (region) {
        UILabel *identifierLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *UUIDLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *majorLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *minorLable = (UILabel *)[cell viewWithTag:4];
        UIImageView* monitoring = (UIImageView *)[cell viewWithTag:5];
        UIImageView *entered = (UIImageView *)[cell viewWithTag:6];
        identifierLabel.text = region.identifier;
        UUIDLabel.adjustsFontSizeToFitWidth = YES;
        UUIDLabel.text = region.proximityUUID.UUIDString;
        
        if (region.major) {
            majorLabel.text = [NSString stringWithFormat:@"major: %@",region.major];
        } else {
            majorLabel.text = @"major : any";
        }
        
        if (region.minor) {
            minorLable.text = [NSString stringWithFormat:@"minor: %@",region.minor];
        } else {
            minorLable.text = @"minor : any";
        }
        
        if (region.isMonitoring) {
            monitoring.image = [UIImage imageNamed:@"green.png"];
        } else {
            monitoring.image = [UIImage imageNamed:@"red.png"];
        }
        
        if (region.hasEntered) {
            entered.image = [UIImage imageNamed:@"green.png"];
        } else {
            entered.image = [UIImage imageNamed:@"red.png"];
        }
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    
    GXBeaconRegion *region = self.beacon.regions[indexPath.row];
    if (region && region.beacons) {
        
        CLBeacon *beacon = region.beacons[indexPath.row];
        if (beacon) {
            UILabel *majorLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *minorLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *RSSILabel = (UILabel *)[cell viewWithTag:3];
            UILabel *accLabel = (UILabel *)[cell viewWithTag:4];
            UILabel *proxLabel = (UILabel *)[cell viewWithTag:5];
            majorLabel.text = [NSString stringWithFormat:@"major %@",beacon.major];
            minorLabel.text = [NSString stringWithFormat:@"minor %@",beacon.minor];
            RSSILabel.text = [NSString stringWithFormat:@"RSSI %ld",(long)beacon.rssi];
            accLabel.text = [NSString stringWithFormat:@"ACC %f",beacon.accuracy];
            
            switch (beacon.proximity) {
                case CLProximityUnknown:
                    proxLabel.text = @"Proximity: Unknown";
                    break;
                case CLProximityFar:
                    proxLabel.text = @"Proximity: Far";
                    break;
                case CLProximityNear:
                    proxLabel.text = @"Proximity: Near";
                    break;
                case CLProximityImmediate:
                    proxLabel.text = @"Proximity: Immediate";
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    return cell;
}

@end
