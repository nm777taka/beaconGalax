#import "GXQuestBoardViewController.h"
#import "GXQuestTableCell.h"
#import "GXTableViewConst.h"
#import "GXCollectionViewCell.h"
#import "GXBucketManager.h"
#import "GXNotification.h"
#import "GXQuestDetialViewController.h"

@interface GXQuestBoardViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *questCollectionView;

@property  NSMutableArray *questArray;
@property GXQuestDetialViewController *detailViewController;

@end

@implementation GXQuestBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - ViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.questCollectionView.delegate = self;
    self.questCollectionView.dataSource = self;
    
    self.questArray = [NSMutableArray new];
    
//    //QuestCreateButton init
//    FUIButton *questCreateButton = [[FUIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 100, self.view.frame.size.height-80 , 200, 50)];
//    questCreateButton.buttonColor = [UIColor sunflowerColor];
//    questCreateButton.shadowColor = [UIColor orangeColor];
//    questCreateButton.shadowHeight = 3.0f;
//    questCreateButton.cornerRadius = 6.0f;
//    questCreateButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
//    [questCreateButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
//    [questCreateButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
//    [questCreateButton setTitle:@"Create"forState:UIControlStateNormal];
//    [questCreateButton bk_addEventHandler:^(id sender){
//        //handler
//        //画面遷移
//        [self performSegueWithIdentifier:@"GoToQuestCreateView" sender:self];
//        
//        
//    } forControlEvents:UIControlEventTouchUpInside];
    
    //TableViewの上に出す
   //[self.view insertSubview:questCreateButton aboveSubview:self.view];
    
    
    //CollectionView
    //self.questCollectionView.backgroundColor = [UIColor cloudsColor];
    
    //notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gxQuestFetchedHandler:) name:GXQuestFetchedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gxQuestDeletedHandler:) name:GXQuestDeletedNotification object:nil];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    
    
    //[self fetchQuest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchQuest
{
   self.questArray = [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
   [self.questCollectionView reloadData];

 
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.questArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    GXCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    
    
    return cell;
    
}

#pragma mark CollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //notificationで選択されたセルのデータを飛ばす
    //詳細画面表示
    if (self.detailViewController == nil) {
        self.detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestDetailView"];
        
    }
    self.detailViewController.quest = self.questArray[indexPath.row];
    self.detailViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.detailViewController.view];
    
}

#pragma mark ConfigureCell
- (void)configureCell:(GXCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 5.0f;
    //cell.layer.masksToBounds = NO; //これ絶対
    //    cell.layer.shadowOffset = CGSizeMake(0,3);
    //    cell.layer.shadowColor = [UIColor asbestosColor].CGColor;
    //    cell.layer.shadowOpacity = 0.8;
    cell.layer.shadowPath = [[UIBezierPath bezierPathWithRect:cell.bounds] CGPath];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    KiiObject *quest = self.questArray[indexPath.row];
    cell.titleLabel.text = [quest getObjectForKey:@"title"];
    cell.descriptionLabel.text = [quest getObjectForKey:@"description"];
    
    
}

#pragma mark GXNotificationHandler
- (void)gxQuestFetchedHandler:(GXNotification *)info
{
    NSLog(@"通知");
    [self.questCollectionView reloadData];
    NSLog(@"questArray:%ld",self.questArray.count);
}

- (void)gxQuestDeletedHandler:(GXNotification *)info
{
    [self fetchQuest];
}

@end
