//
//  GXQuestDetailViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestDetailViewController.h"

@interface GXQuestDetailViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdUserLabel;
@property (weak, nonatomic) IBOutlet CSAnimationView *detailPanel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbIconView;
- (IBAction)questAction:(id)sender;
- (IBAction)closeAction:(id)sender;

@end

@implementation GXQuestDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma makr - ViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _fbIconView.layer.cornerRadius = 20.f;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.alpha = 1.0f;
    [self.detailPanel startCanvasAnimation];
    [self configureDetailPanel];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)configureDetailPanel
{
    _titleLabel.text = _quest.title;
    _fbIconView.profileID = _quest.fb_id;
}


#pragma ButtonAction
- (IBAction)questAction:(id)sender {
}

- (IBAction)closeAction:(id)sender {
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.view.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];
}

@end
