//
//  GXUserProfileViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXUserProfileViewController.h"
#import "GXViewConst.h"
#import <FlatUIKit/FlatUIKit.h>

#define PADDING_TOP_BUTTOM 0
#define PADDING_LEFT_RIGHT 0
#define CORNER_RADIUS 0
#define SHADOW_RADIUS 0
#define SHADOW_OPACITY 0


@interface GXUserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property NSMutableArray *scrollerViews;

@end

@implementation GXUserProfileViewController

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
    //ScrollView Init
    self.scrollerViews = [NSMutableArray new];
    
    UINib *userProfileNib = [UINib nibWithNibName:@"userProfile" bundle:nil];
    NSLog(@"nib load %@",userProfileNib);
    
    //プロフィール
    UIView *userProfileView = [[userProfileNib instantiateWithOwner:self options:nil]objectAtIndex:0];
    userProfileView.backgroundColor = [UIColor blackColor];
    
    //獲得ポイント
    UIView *header1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    header1.backgroundColor = [UIColor colorWithRed:0.106 green:0.095 blue:0.092 alpha:1.000];
    UILabel *h1Lable = [[UILabel alloc] initWithFrame:CGRectMake(header1.center.x - 50,0, 100, 50)];
    h1Lable.font = [UIFont boldFlatFontOfSize:14];
    h1Lable.textColor  = [UIColor whiteColor];
    h1Lable.text = @"獲得ポイント";
    h1Lable.textAlignment = NSTextAlignmentCenter;
    [header1 addSubview:h1Lable];
    
    //達成したクエスト
    UIView *header2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    header2.backgroundColor = [UIColor colorWithRed:0.106 green:0.095 blue:0.092 alpha:1.000];
    UILabel *h2Label = [[UILabel alloc] initWithFrame:CGRectMake(header2.center.x - 100, 0, 200, 50)];
    h2Label.font = [UIFont boldFlatFontOfSize:14];
    h2Label.textColor = [UIColor whiteColor];
    h2Label.text = @"達成したクエスト";
    h2Label.textAlignment = NSTextAlignmentCenter;
    [header2 addSubview:h2Label];
    
    
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height)];
    [_scrollView setScrollEnabled:YES];
    _scrollView.backgroundColor = [UIColor blackColor];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    
    [self addView:userProfileView];
    [self addView:header1];
    [self addView:header2];
    
    
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

#pragma mark - ScrollViewMethod
- (void)addView:(UIView *)view
{
    UIView *lastView = [_scrollView.subviews lastObject];
    _scrollerViews = [[NSMutableArray alloc] initWithArray:_scrollView.subviews];
    NSLog(@"ScrollViewCount: %d",_scrollView.subviews.count);
    float y = lastView.frame.origin.y + lastView.frame.size.height+PADDING_TOP_BUTTOM;
    if(lastView == nil) {
        y = 10;
    }
    
    CGRect frame = view.frame;
    frame.origin.y = y;
    frame.origin.x = PADDING_LEFT_RIGHT;
    view.frame = frame;
    
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = CORNER_RADIUS;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowRadius = SHADOW_RADIUS;
    view.layer.shadowOpacity = SHADOW_OPACITY;
    
    //viewサイズがscrollViewのサイズを超えてたら
    //scrollViewのサイズを更新する
    if((view.frame.origin.y + view.frame.size.height) >= _scrollView.frame.size.height) {
        
        //new height
        float newHeight = view.frame.origin.y + view.frame.size.height + PADDING_TOP_BUTTOM;
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, newHeight)];
        
    }
    
    [_scrollView addSubview:view];
    
    
}


@end
