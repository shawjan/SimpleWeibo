//
//  MineViewController.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/19.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "MineViewController.h"
#import <WeiboSDK.h>
#import "TabBarViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MineViewController ()<WBHttpRequestDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *avartorImg;
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.avartorImg.clipsToBounds = YES;
    self.avartorImg.layer.masksToBounds = YES;
    self.avartorImg.layer.cornerRadius = self.avartorImg.frame.size.height / 4;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(appDelegate.profile_url){
        [self.avartorImg sd_setImageWithURL:[NSURL URLWithString:appDelegate.profile_url]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)quitButtonClicked:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [WeiboSDK logOutWithToken:appDelegate.wbToken delegate:self withTag:appDelegate.wbCurrentUserId];
}

-(void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    [self updateLoginOutStatus:@"登出失败！请再尝试！"];
    NSLog(@"%ld :%@ -%@", error.code, error.domain, error.userInfo);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"登出成功！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:Weibo_AuthData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"登出成功！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if([appDelegate.window.rootViewController isKindOfClass:[UITabBarController class]]){
            [appDelegate.window.rootViewController performSegueWithIdentifier:@"Show LoginView" sender:self];
        }
    }];
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)updateLoginOutStatus:(NSString*)result
{
    

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
