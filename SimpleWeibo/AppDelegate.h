//
//  AppDelegate.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/18.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) NSString *wbToken;
@property(nonatomic, copy) NSString *wbRefreshToken;
@property(nonatomic, copy) NSString *wbCurrentUserId;
@property(nonatomic, copy) NSDate *expirationDate;
@property(nonatomic, copy) NSString *screen_name;
@property(nonatomic, copy) NSString *profile_url;
@property(nonatomic, copy) NSString *email;// 需要高级授权，没有权限
@property(nonatomic, copy) NSString *userId;
@end

