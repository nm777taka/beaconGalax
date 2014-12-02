//
//  GXSettingTableViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/18.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXSettingTableViewController.h"
#import "GXGoogleFormViewController.h"

@interface GXSettingTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSInteger selectedCellIndex;
- (IBAction)closeView:(id)sender;

@end

@implementation GXSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    //beacon setting
                    //segue
                    [self performSegueWithIdentifier:@"beacon" sender:self];
                    break;
                    
                case 1: //実験前（所属意識)
                    _selectedCellIndex = indexPath.row;
                    [self performSegueWithIdentifier:@"gotoGoogleForm" sender:self];
                    break;
                    
                case 2: //ユーザビリティ
                    _selectedCellIndex = indexPath.row;
                    [self performSegueWithIdentifier:@"gotoGoogleForm" sender:self];
                    break;
                
                case 3: //実験後(所属意識)
                    _selectedCellIndex = indexPath.row;
                    [self performSegueWithIdentifier:@"gotoGoogleForm" sender:self];
                    break;
                    
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"beacon"]) {
        
    } else if ([segue.identifier isEqualToString:@"gotoGoogleForm"]) {
        GXGoogleFormViewController *googleFormView = segue.destinationViewController;
        switch (_selectedCellIndex) {
            case 1:
                googleFormView.urlString = @"https://docs.google.com/forms/d/1_ZWsg4vTu8t_aqM_MIwsquaGUut-esRFJ122nmiR73Y/viewform?usp=send_form";
                break;
                
            case 2:
                googleFormView.urlString = @"https://docs.google.com/forms/d/1QtWs_m8Bvdb3MXfnwtPZ0S3f0dQvj5UmKsKA9Ksg8QA/viewform?usp=send_form";
                break;
                
            case 3:
                googleFormView.urlString = @"https://docs.google.com/forms/d/1dDg9Wq2eLVM5X4UscVikLQIjalXY8Ct2XpXFkM2Qmlw/viewform?usp=send_form";
                break;
                
            default:
                break;
        }
        
    }
}


- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
