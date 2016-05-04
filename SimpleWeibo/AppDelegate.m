//
//  AppDelegate.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/18.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "AppDelegate.h"
#import <WeiboSDK.h>
#import "LoginViewController.h"
#import "TabBarViewController.h"

@interface AppDelegate ()<WeiboSDKDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:APP_KEY];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:Weibo_AuthData];
    if([dic objectForKey:Weibo_UserId] && [dic objectForKey:Weibo_RefreshToken] && [dic objectForKey:Weibo_RefreshToken] && [dic objectForKey:Weibo_ExpirationDate]){
        self.wbCurrentUserId = [dic objectForKey:Weibo_UserId];
        self.wbRefreshToken = [dic objectForKey:Weibo_RefreshToken];
        self.wbToken = [dic objectForKey:Weibo_AccessTokenKey];
        self.expirationDate = [dic objectForKey:Weibo_ExpirationDate];
//        NSString *urlStr = [NSString stringWithFormat:@"%@%@", Weibo_PublicLink, @"account/get_uid.json"];
//        [WBHttpRequest requestWithURL:urlStr
//                           httpMethod:@"GET"
//                               params:@{@"access_token":self.wbToken}
//                                queue:[NSOperationQueue mainQueue]
//                withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//                    if(!error){
//                        self.userId = [NSString stringWithFormat:@"%@", [result objectForKey:@"uid"]];
//                        [self getUserInfo];
//                    }else{
//                        NSLog(@"%ld :%@ - %@", error.code, error.domain, error.userInfo);
//                    }
//                    
//                }];
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:Weibo_UserLoginHistory];
        if([dic objectForKey:self.wbCurrentUserId]){
            self.screen_name = [[dic objectForKey: self.wbCurrentUserId] objectForKey:@"screen_name"];
            self.profile_url = [[dic objectForKey: self.wbCurrentUserId] objectForKey:@"profile_image_url"];
            self.userId = [[dic objectForKey: self.wbCurrentUserId] objectForKey:@"uid"];
        }
        NSDate *now = [NSDate date];
        if([now compare:self.expirationDate] == NSOrderedDescending){
            [WBHttpRequest requestForRenewAccessTokenWithRefreshToken:self.wbRefreshToken queue:[NSOperationQueue mainQueue] withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                if(!error){
                    self.wbToken = [(WBAuthorizeResponse *)result accessToken];
                    self.wbCurrentUserId = [(WBAuthorizeResponse *)result userID];
                    self.wbRefreshToken = [(WBAuthorizeResponse *)result refreshToken];
                    self.expirationDate = [(WBAuthorizeResponse*)result expirationDate];
                    
                    if(self.wbToken && self.wbRefreshToken && self.wbToken && self.expirationDate){
                        NSDictionary *authData = @{Weibo_AccessTokenKey:self.wbToken,
                                                   Weibo_ExpirationDate:self.expirationDate,
                                                   Weibo_RefreshToken:self.wbRefreshToken,
                                                   Weibo_UserId:self.wbCurrentUserId};
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:Weibo_AuthData];
                        [[NSUserDefaults standardUserDefaults] setObject:authData forKey:Weibo_AuthData];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                    }
                }
            }];
        }
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

-(void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        NSLog(@"%@", message);
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbToken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserId = userID;
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        self.wbToken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserId = [(WBAuthorizeResponse *)response userID];
        self.wbRefreshToken = [(WBAuthorizeResponse *)response refreshToken];
        self.expirationDate = [(WBAuthorizeResponse*)response expirationDate];
        
        if(self.wbToken && self.wbRefreshToken && self.wbToken && self.expirationDate){
            NSDictionary *authData = @{Weibo_AccessTokenKey:self.wbToken,
                                       Weibo_ExpirationDate:self.expirationDate,
                                       Weibo_RefreshToken:self.wbRefreshToken,
                                       Weibo_UserId:self.wbCurrentUserId};
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:Weibo_AuthData];
            [[NSUserDefaults standardUserDefaults] setObject:authData forKey:Weibo_AuthData];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //UIViewController *viewController = [self getCurrentVC];
//            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            UIViewController *viewController = [sb instantiateViewControllerWithIdentifier:@"Login ViewCon"];
//            if([viewController isKindOfClass:[LoginViewController class]]){
//                LoginViewController *loginVC = (LoginViewController*)viewController;
//                [loginVC dismissViewControllerAnimated:YES completion:nil];
//            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginVC object:nil];
            NSString *urlStr = [NSString stringWithFormat:@"%@%@", Weibo_PublicLink, @"account/get_uid.json"];
            [WBHttpRequest requestWithURL:urlStr
                               httpMethod:@"GET"
                                   params:@{@"access_token":self.wbToken}
                                    queue:[NSOperationQueue mainQueue]
                    withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        if(!error){
                            self.userId =  [NSString stringWithFormat:@"%@", [result objectForKey:@"uid"]];
                            [self getUserInfo];
                        }else{
                            NSLog(@"%ld :%@ - %@", error.code, error.domain, error.userInfo);
                        }
                        
                    }];
            
        }
        
    }
}

-(void)getUserInfo
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", Weibo_PublicLink, @"users/show.json"];
    [WBHttpRequest requestWithURL:urlStr
                       httpMethod:@"GET"
                           params:@{@"access_token":self.wbToken,
                                    @"uid":self.userId}
                            queue:[NSOperationQueue mainQueue]
            withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                if(!error){
                    self.screen_name = [result objectForKey:@"screen_name"];
                    self.profile_url = [result objectForKey:@"avatar_large"];
                    if(self.screen_name != nil && self.profile_url != nil){
                        NSMutableDictionary *userHistory = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:Weibo_UserLoginHistory]];
                        if(userHistory == nil){
                            userHistory = [NSMutableDictionary dictionary];
                        }
                        NSDictionary *dic = @{@"screen_name": self.screen_name,
                                              @"profile_image_url": self.profile_url,
                                              @"uid":self.userId};
                        [userHistory setObject:dic forKey:self.wbCurrentUserId];
                        [[NSUserDefaults standardUserDefaults] setObject:userHistory forKey:Weibo_UserLoginHistory];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }else{
                    NSLog(@"%ld :%@ - %@", error.code, error.domain, error.userInfo);
                }
                
            }];
}

-(UIViewController*)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow *window = self.window;
    if(self.window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows){
            if(tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }else{
        result = window.rootViewController;
    }
    
    return result;
}

-(void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
