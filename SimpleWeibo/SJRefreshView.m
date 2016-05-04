//
//  SJRefreshView.m
//  SimpleWeibo
//
//  Created by shawjan on 16/5/3.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "SJRefreshView.h"
#import <Masonry/Masonry.h>

@interface SJRefreshView ()

@property(nonatomic, strong) UIActivityIndicatorView *activityView;
@property(nonatomic, strong) NSString *labelText;

@end

@implementation SJRefreshView

-(NSString *)labelText
{
    return _viewType == SJRefreshHeaderView ? @"下拉刷新" : @"上拉加载";
}

-(void)setIsRefreshing:(BOOL)isRefreshing
{
    _isRefreshing = isRefreshing;
    _label.text = isRefreshing ? @"加载中" : self.labelText;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        
        CGFloat actViewWith = frame.size.height / 3;
        _activityView = [[UIActivityIndicatorView alloc] init];
        _activityView.hidesWhenStopped = YES;
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview:_activityView];
        [_activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(actViewWith, actViewWith));
        }];
        
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 1;
        _label.font = [UIFont systemFontOfSize:15.0];
        _label.textColor = [UIColor blackColor];
        [self addSubview:_label];
        _label.textAlignment = NSTextAlignmentCenter;
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
            make.right.mas_equalTo(self.mas_right);
            make.top.mas_equalTo(self.activityView.mas_bottom);
        }];
        
        //self.hidden = YES;
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)startAnimation{
    [self.activityView startAnimating];
    //self.hidden = NO;
    self.isRefreshing = YES;
    
}

-(void)stopAnimation{
    [self.activityView stopAnimating];
    //self.hidden = YES;
    self.isRefreshing = NO;
}

@end
