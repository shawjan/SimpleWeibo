//
//  SJRefreshView.h
//  SimpleWeibo
//
//  Created by shawjan on 16/5/3.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ENUM(NSInteger, SJRefreshViewType){
    SJRefreshHeaderView,
    SJRefreshFooterView,
};

@interface SJRefreshView : UIView

@property(nonatomic, strong) UILabel *label;

@property(nonatomic, assign) BOOL isRefreshing;
@property(nonatomic, assign) enum SJRefreshViewType viewType;

-(void)startAnimation;
-(void)stopAnimation;

@end
