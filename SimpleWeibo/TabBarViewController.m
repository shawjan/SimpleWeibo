//
//  TabBarViewController.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/20.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "TabBarViewController.h"
#import "ComposeViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface TabBarViewController ()
@property(nonatomic, strong) UIButton *composeBtn;
@end

@implementation TabBarViewController

-(void)setSelectedIndex:(NSUInteger)selectedIndex
{
    
}

-(UIButton *)composeBtn
{
    if(!_composeBtn){
        CGFloat tabBarHeight = self.tabBar.frame.size.height;
        CGFloat tabBarWidth = self.tabBar.frame.size.width;
        _composeBtn = [[UIButton alloc] initWithFrame:CGRectMake((tabBarWidth - tabBarHeight)/ 2 , 4, tabBarHeight, tabBarHeight - 6)];
        [_composeBtn setImage:[UIImage imageNamed:@"tabbar_compose_icon_add"] forState:UIControlStateNormal];
        [_composeBtn setBackgroundColor:[UIColor colorWithRed:249 /255.0 green:102 / 255.0 blue:0.0 alpha:1.0]];
        [self.tabBar addSubview:_composeBtn];
    }
    return _composeBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITabBarItem *item = self.tabBar.items[0];
    UIImage *image = [UIImage imageNamed:@"tabbar_home_highlighted"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setSelectedImage:image];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:249 /255.0 green:102 / 255.0 blue:0.0 alpha:1.0]} forState:UIControlStateSelected];
    item = self.tabBar.items[2];
    image = [UIImage imageNamed:@"tabbar_profile_highlighted"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setSelectedImage:image];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:249 /255.0 green:102 / 255.0 blue:0.0 alpha:1.0]} forState:UIControlStateSelected];
}

-(void)awakeFromNib
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.composeBtn addTarget:self action:@selector(composeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(!(appDelegate.wbCurrentUserId && appDelegate.wbRefreshToken && appDelegate.wbToken && appDelegate.expirationDate)){
        [self performSegueWithIdentifier:@"Show LoginView" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)composeBtnClicked:(id)sender
{
    //UINavigationController *navCon = [[UINavigationController alloc] init];
    //ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    [self performSegueWithIdentifier:@"Show ComposeVC" sender:self];
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
