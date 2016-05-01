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


@interface MainTableViewController ()

@property(nonatomic, strong)NSMutableDictionary *weiboInfo;
@property(nonatomic, strong) NSMutableArray *statusesInfo;
@property(nonatomic, strong) YYFPSLabel *fpsLabel;

@end

#define Weibo_Status @"statuses"
//#define Weibo_User @"user"

@implementation MainTableViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToCellButtonClicked:) name:@"RespondToCellButton" object:nil];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(appDelegate.screen_name){
        self.navigationItem.title = appDelegate.screen_name;
    }
    //获取微博数据的借口，但是由于接口数据调整，拿不到一些图片、视频具体的链接，因此还是换成本地数据。
//    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    NSString *urlStr = [NSString stringWithFormat:@"%@%@", Weibo_PublicLink, @"statuses/public_timeline.json"];
//    [WBHttpRequest requestWithURL:urlStr
//                       httpMethod:@"GET"
//                           params:@{@"access_token":appDelegate.wbToken,
//                                    @"count":@"50",
//                                    @"page":@"1"}
//                            queue:[NSOperationQueue mainQueue]
//            withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//                if(!error){
//                    if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"statuses"] != nil){
//                        NSArray *statuses = (NSArray*)[result objectForKey:@"statuses"];
//                        for(NSDictionary *dic in statuses){
//                            StatusModel *status = [[StatusModel alloc] init];
//                            [status reflectDataFromOtherObject:dic];
//                            [self.statusesInfo addObject:status];
//                        }
//                    }
//                    NSLog(@"%@", self.statusesInfo);
//                    [self.tableView reloadData];
//                }else{
//                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%ld:%@ - %@", error.code, error.domain, error.userInfo] preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//                    [alert addAction:alertAction];
//                    [self presentViewController:alert animated:YES completion:nil];
//                }
//            }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RespondToCellButton" object:nil];
}

-(void)respondToCellButtonClicked:(NSNotification *)noti
{
    NSDictionary *info = [noti userInfo];
    if([info objectForKey:RepostButtonClicked]){
        NSLog(@"转发");
    }else if([info objectForKey:CommentButtonClicked]){
        NSLog(@"评论");
    }else if([info objectForKey:LikeButtonClicked]){
        NSLog(@"赞");
    }else if([info objectForKey:LabelClicked]){
        
    }else if([info objectForKey:ImageViewClicked]){
        
    }else if([info objectForKey:UserAvatorClicked]){
        
    }else if([info objectForKey:PageViewClicked]){
        
    }else if([info objectForKey:MovieViewClicked]){
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableDictionary *)weiboInfo
{
    if(!_weiboInfo){
        //test data
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
        for(NSDictionary *dic in [self.weiboInfo objectForKey:Weibo_Status]){
            StatusModel *status = [[StatusModel alloc] init];
            [status reflectDataFromOtherObject:dic];
            [_statusesInfo addObject:status];
        }
    }
    return _statusesInfo;
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
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    return cell;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.fpsLabel.alpha = 1;
        } completion:NULL];
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
