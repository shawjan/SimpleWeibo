//
//  MainTableViewController.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/19.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "MainTableViewController.h"
#import "WeiboTableViewCell.h"
#import "YYFPSLabel.h"
#import "StatusModel.h"
#import "UserModel.h"
#import "WebViewController.h"
#import "AppDelegate.h"
#import <WeiboSDK/WeiboSDK.h>
#import "SJRefreshView.h"
#import "FullScreenImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ComposeViewController.h"
#import "WebViewController.h"

#define RefreshViewHeight 50

@interface MainTableViewController ()

@property(nonatomic, strong)NSMutableDictionary *weiboInfo;
@property(nonatomic, strong) NSMutableArray *statusesInfo;
@property(nonatomic, strong) YYFPSLabel *fpsLabel;
@property(nonatomic, strong) UIScrollView *scrollerView;

@property(nonatomic, strong) SJRefreshView *headerView;
@property(nonatomic, strong) SJRefreshView *footerView;
@property(nonatomic, assign) NSInteger currentPage;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *requestTypeBtn;

@end

#define Weibo_Status @"statuses"
//#define Weibo_User @"user"

@implementation MainTableViewController

-(SJRefreshView *)headerView
{
    if(!_headerView){
        _headerView = [[SJRefreshView alloc] initWithFrame:CGRectMake(0, - RefreshViewHeight, ScreenWidth, RefreshViewHeight)];
        //_headerView.label.text = @"下拉刷新...";
        //_headerView.hidden = YES;
        _headerView.isRefreshing = NO;
        _headerView.viewType = SJRefreshFooterView;
        [self.tableView addSubview:_headerView];
    }
    return _headerView;
}

-(SJRefreshView *)footerView
{
    if(!_footerView){
        _footerView = [[SJRefreshView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, RefreshViewHeight)];
        _footerView.viewType = SJRefreshFooterView;
        _footerView.isRefreshing = NO;
        //_footerView.hidden = YES;
        self.tableView.tableFooterView = _footerView;
    }
    return _footerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelection = YES;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.backgroundView.backgroundColor = [UIColor grayColor];
    [self.tableView registerClass:[WeiboTableViewCell class] forCellReuseIdentifier:@"WeiboTBCIdentifier"];
    
    self.fpsLabel = [YYFPSLabel new];
    [self.fpsLabel sizeToFit];
    self.fpsLabel.textColor = [UIColor whiteColor];
    CGFloat height = 50;
    self.fpsLabel.frame = CGRectMake(height, self.view.frame.size.height - height - self.fpsLabel.frame.size.height, self.fpsLabel.frame.size.width, self.fpsLabel.frame.size.height);
    self.fpsLabel.alpha = 0;
    [self.navigationController.view addSubview:self.fpsLabel];
    [self.navigationController.view bringSubviewToFront:self.fpsLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToCellButtonClicked:) name:RespondToCellButton object:nil];
    
    //self.footerView.backgroundColor = [UIColor yellowColor];
    //self.headerView.backgroundColor = [UIColor yellowColor];
    self.scrollerView = self.tableView;
    self.headerView.hidden = YES;
    self.footerView.hidden = YES;
    //self.tableView.scrollsToTop = YES;
    [self.scrollerView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    //requestForLocalData = YES;

    [self.tableView reloadData];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RespondToCellButton object:nil];
    //[self.tableView removeObserver:self forKeyPath:@"contentOffSet" context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    //NSLog(@"%f", self.tableView.contentOffset.y);
}

-(void)respondToCellButtonClicked:(NSNotification *)noti
{
    NSDictionary *info = [noti userInfo];
    if([[info objectForKey:WhichType] isEqualToString:RepostButtonClicked]){
        NSLog(@"转发");
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        ComposeViewController *compose = [sb instantiateViewControllerWithIdentifier:@"Compose View Con"];
        compose.title = @"转发微博";
        compose.navigationItem.rightBarButtonItem.enabled = NO;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:compose];
        [self presentViewController:nav animated:YES completion:nil];
    }else if([[info objectForKey:WhichType] isEqualToString:CommentButtonClicked]){
        NSLog(@"评论");
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        ComposeViewController *compose = [sb instantiateViewControllerWithIdentifier:@"Compose View Con"];
        compose.title = @"评论微博";
        compose.navigationItem.rightBarButtonItem.enabled = NO;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:compose];
        [self presentViewController:nav animated:YES completion:nil];
    }else if([[info objectForKey:WhichType] isEqualToString:LikeButtonClicked]){
        NSLog(@"赞");
        WeiboTableViewCell *cell = [noti object];
        if([cell isKindOfClass:[WeiboTableViewCell class]]){
            [cell setLike];
        }
    }else if([[info objectForKey:WhichType] isEqualToString:LabelClicked]){
        
    }else if([[info objectForKey:WhichType] isEqualToString:ImageViewClicked]){
        NSLog(@"图片点击");
        NSDictionary *dic = [noti object];
        int index = ((NSNumber*)[dic objectForKey:WhichImage]).intValue;
        NSDictionary *imageDic = [dic objectForKey:ImageData][index];
        NSURL *url = [NSURL URLWithString:[imageDic objectForKey:@"url"]];
        FullScreenImageView *imageView = [[FullScreenImageView alloc] initWithFrame:self.view.frame withType:FullScreenImageViewNoneType];
        [self.view.window addSubview:imageView];
        [imageView.imageView sd_setImageWithURL:url];
    }else if([[info objectForKey:WhichType]isEqualToString:UserAvatorClicked]){
        NSLog(@"头像");
    }else if([[info objectForKey:WhichType]isEqualToString:PageViewClicked]){
        NSLog(@"链接");
        WebViewController *webCon = [[WebViewController alloc] initWithURL:[noti object]];
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:webCon];
        [self presentViewController:navCon animated:YES completion:nil];
    }else if([[info objectForKey:WhichType]isEqualToString:MovieViewClicked]){
        NSLog(@"电影链接");
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(appDelegate.screen_name){
        self.navigationItem.title = appDelegate.screen_name;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableDictionary *)weiboInfo
{
    if(!_weiboInfo){
        //test data
        if(requestForLocalData){
            for(int i = 7; i < 8; ++i){
                NSString *string = [NSString stringWithFormat:@"weibo_%d", i];
                NSError*error;
                NSURL *url = [[NSBundle mainBundle] URLForResource:string withExtension:@".json"];
                NSData *data = [NSData dataWithContentsOfURL:url];
                NSMutableDictionary *mutalDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if(i == 7){
                    _weiboInfo = mutalDic;
                }else{
                    NSMutableArray *mutalArray = [_weiboInfo objectForKey:Weibo_Status];
                    [mutalArray addObjectsFromArray:[mutalDic objectForKey:Weibo_Status]];
                    [_weiboInfo setValue:mutalArray forKey:Weibo_Status];
                }
            }
        }
//        NSString *jsonStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
//        NSLog(@"%@", jsonStr);
    }
    return _weiboInfo;
}

-(NSMutableArray *)statusesInfo
{
    if(!_statusesInfo){
        _statusesInfo = [[NSMutableArray alloc] init];
        //test data
        if(requestForLocalData){
            for(NSDictionary *dic in [self.weiboInfo objectForKey:Weibo_Status]){
                StatusModel *status = [[StatusModel alloc] init];
                [status reflectDataFromOtherObject:dic];
                [_statusesInfo addObject:status];
            }
        }
    }
    return _statusesInfo;
}
- (IBAction)requestTypeBtnClicked:(UIBarButtonItem *)sender {
    requestForLocalData = !requestForLocalData;
    sender.title = requestForLocalData ? @"本地" : @"网络";
    if(!requestForLocalData){
        [self.statusesInfo removeAllObjects];
        [self sendRequestToWeibo:YES];
        self.currentPage = 1;
    }else{
        self.statusesInfo = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.statusesInfo count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatusModel *status  = self.statusesInfo[indexPath.section];
    if(status.height){
        return status.height;
    }
    CGFloat height = [WeiboTableViewCell getCellHeightWithStatus:status];
    height += 19;//文本计算label高度不准确
    status.height = height;
    //NSLog(@"%f", height);
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeiboTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiboTBCIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //NSDictionary *userModel = [[self.statusesInfo objectAtIndex:indexPath.section]objectForKey:Weibo_User];
    StatusModel *status  = self.statusesInfo[indexPath.section];
    
    [cell setStatusViewData:status];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    return cell;
}

-(void)sendRequestToWeibo:(BOOL) isPullRefresh
{
    if(!requestForLocalData){
        if(isPullRefresh){
            self.currentPage = 1;
        }else{
            ++self.currentPage;
        }
        //获取微博数据的借口，但是由于接口数据调整，拿不到一些图片、视频具体的链接，因此还是换成本地数据。
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", Weibo_PublicLink, @"statuses/friends_timeline.json"];
        NSString *pageStr = [NSString stringWithFormat:@"%ld", self.currentPage];
        [WBHttpRequest requestWithURL:urlStr
                           httpMethod:@"GET"
                               params:@{@"access_token":appDelegate.wbToken,
                                        @"count":@"50",
                                        @"page":pageStr}
                                queue:[NSOperationQueue mainQueue]
                withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                    if(!error){
                        if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"statuses"] != nil){
                            if(isPullRefresh){
                                [self.statusesInfo removeAllObjects];
                            }
                            NSArray *statuses = (NSArray*)[result objectForKey:@"statuses"];
                            if(statuses.count <= 0){
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"没有更多数据了~" preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                                [alert addAction:alertAction];
                                [self presentViewController:alert animated:YES completion:nil];
                                [self endLoadData:isPullRefresh];
                                return ;
                            }
                            for(NSDictionary *dic in statuses){
                                StatusModel *status = [[StatusModel alloc] init];
                                [status reflectDataFromOtherObject:dic];
                                [self.statusesInfo addObject:status];
                            }
                        }
                        NSLog(@"%@", self.statusesInfo);
                        [self.tableView reloadData];
                    }else{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%ld:%@ - %@", error.code, error.domain, error.userInfo] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                        [alert addAction:alertAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    [self endLoadData:isPullRefresh];
                }];
    }else{
        [self endLoadData:isPullRefresh];
    }
}

-(void)endLoadData:(BOOL) isPullRefresh
{
    if(isPullRefresh){
        [self.headerView stopAnimation];
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        [self.tableView setContentOffset:CGPointMake(0, -64) animated:NO];
        self.headerView.hidden = YES;
    }else{
        [self.footerView stopAnimation];
        //self.tableView.contentInset = UIEdgeInsetsZero;
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - ScreenHeight) animated:YES];
        self.footerView.hidden = YES;
    }
}

-(void)startLoadData:(BOOL)isPullRefresh
{
    if(isPullRefresh){
        [self.headerView startAnimation];
        CGRect frame = self.headerView.frame;
        frame.origin.y = - RefreshViewHeight;
        self.headerView.frame = frame;
        [self.tableView setContentOffset:CGPointMake(0, -64 -RefreshViewHeight) animated:NO];
        self.tableView.contentInset = UIEdgeInsetsMake(-64 - RefreshViewHeight, 0, 0, 0);
    }else{
        [self.footerView startAnimation];
        //CGRect frame = self.footerView.frame;
        //frame.origin.y = -64 - RefreshViewHeight;
        //self.footerView.frame = frame;
        //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.footerView.frame.origin.y, 0);
        [self.tableView setContentOffset: CGPointMake(0, self.tableView.contentSize.height -  ScreenHeight) animated:NO];
    }
    [self sendRequestToWeibo: isPullRefresh];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.fpsLabel.alpha = 1;
        } completion:NULL];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.tableView.contentOffset.y < -64 - RefreshViewHeight){
        //self.footerView.hidden = NO;
        NSLog(@"刷新数据");
        if(self.tableView.isDragging){
            //CGRect frame = self.headerView.frame;
            //frame.origin.y = self.tableView.contentOffset.y + RefreshViewHeight;
            //self.headerView.frame = frame;
        }
        self.headerView.hidden = NO;
        if(!self.tableView.isDragging){
            [self startLoadData:YES];
        }
    }
    if (self.tableView.contentOffset.y > self.tableView.contentSize.height - ScreenHeight + RefreshViewHeight) {
        //self.headerView.hidden = NO;
        NSLog(@"加载数据");
        self.footerView.hidden = NO;
        if(self.tableView.isDragging){
            //CGRect frame = self.footerView.frame;
            //frame.origin.y = self.tableView.contentOffset.y - RefreshViewHeight;
            //self.footerView.frame = frame;
        }
        if(!self.tableView.isDragging){
            [self startLoadData:NO];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (self.fpsLabel.alpha != 0) {
            [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.fpsLabel.alpha = 0;
            } completion:NULL];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.fpsLabel.alpha != 0) {
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.fpsLabel.alpha = 0;
        } completion:NULL];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (self.fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.fpsLabel.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}

-(void)pushWebViewController:(NSURL*)url
{
    WebViewController *webViewVC = [[WebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webViewVC animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeiboTableViewCell *cell = (WeiboTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%f", CGRectGetHeight(cell.frame));
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
