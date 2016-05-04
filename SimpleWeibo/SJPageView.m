//
//  SJPageView.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/26.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "SJPageView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface SJPageView ()

@property(nonatomic, strong) UIImageView *leftImageView;
@property(nonatomic, strong) UILabel *titleLbl;
@property(nonatomic, strong) UILabel *contentLbl;
@property(nonatomic, strong) UILabel *tipLbl;
@property(nonatomic, strong) UIButton *button;
@end

#define SJPageViewHeight 60.0

@implementation SJPageView

-(instancetype)init
{
    self = [super init];
    if(self){
        [self setupView];
    }
    return self;
}

-(void)setupView
{
    self.leftImageView = [[UIImageView alloc] init];
    [self addSubview:self.leftImageView];
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top);
        make.size.mas_equalTo(CGSizeMake(SJPageViewHeight, SJPageViewHeight));
    }];
    
    self.titleLbl = [[UILabel alloc] init];
    [self addSubview:self.titleLbl];
    self.titleLbl.numberOfLines = 1;
    self.titleLbl.font = [UIFont systemFontOfSize:MainContentSize];
    self.titleLbl.backgroundColor = [UIColor clearColor];
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(SJPageViewHeight);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(ScreenWidth - SJPageViewHeight - 20);
    }];
    
    self.contentLbl = [[UILabel alloc] init];
    [self addSubview:self.contentLbl];
    self.contentLbl.numberOfLines = 1;
    self.contentLbl.font = [UIFont systemFontOfSize:SubContentSize];
    self.contentLbl.backgroundColor = [UIColor clearColor];
    [self.contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLbl.mas_bottom).offset(6.5);
        make.left.mas_equalTo(self.titleLbl.mas_left);
        make.width.mas_equalTo(self.titleLbl.mas_width);
    }];
    
    self.tipLbl = [[UILabel alloc] init];
    [self addSubview:self.tipLbl];
    self.tipLbl.numberOfLines = 1;
    self.tipLbl.font = [UIFont systemFontOfSize:SubContentSize];
    self.tipLbl.backgroundColor = [UIColor clearColor];
    [self.tipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLbl.mas_bottom).offset(6.5);
        make.left.mas_equalTo(self.titleLbl.mas_left);
        make.width.mas_equalTo(self.titleLbl.mas_width);
    }];
    
    self.button = [[UIButton alloc] init];
    [self.button setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.button];
    [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.mas_width);
        make.top.mas_equalTo(self.mas_top);
        make.left.mas_equalTo(self.mas_left);
        make.height.mas_equalTo(SJPageViewHeight);
    }];
    self.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:242.0/255.0 alpha:1.0];
}

-(void)buttonClicked:(UIButton*)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:RespondToCellButton object:[NSURL URLWithString:[self.pageInfo objectForKey:@"page_url"]] userInfo:@{WhichType:PageViewClicked}];
}

-(void)setPageInfo:(NSDictionary *)pageInfo
{
    _pageInfo = pageInfo;
    if([self.pageInfo objectForKey:@"page_pic"] != nil && ![[self.pageInfo objectForKey:@"page_pic"] isKindOfClass:[NSNull class]]){
        self.leftImageView.hidden = NO;
        [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:[self.pageInfo objectForKey:@"page_pic"]]];
    }else{
        [self.titleLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
        }];
        self.leftImageView.hidden = YES;
    }
    
    if([pageInfo objectForKey:@"page_title"]){
        self.titleLbl.hidden = NO;
        self.titleLbl.text = [pageInfo objectForKey:@"page_title"];
    }else{
        self.titleLbl.hidden = YES;
    }
    
    NSString *str;
    if([pageInfo objectForKey:@"page_desc"]){
        str = [pageInfo objectForKey: @"page_desc"];
    }else if([pageInfo objectForKey:@"content2"]){
        str = [pageInfo objectForKey: @"page_desc"];
    }else if([pageInfo objectForKey:@"content3"]){
        str = [pageInfo objectForKey: @"page_desc"];
    }
    if(str){
        self.contentLbl.hidden = NO;
        self.contentLbl.text = str;
    }
    else{
        self.contentLbl.hidden = YES;
    }
    
    if([pageInfo objectForKey:@"tips"])
    {
        self.tipLbl.hidden = NO;
        self.tipLbl.text = [pageInfo objectForKey:@"tips"];
    }else{
        self.tipLbl.hidden = YES;
    }
}

+(CGFloat)getHeightOfSJPageView
{
    return SJPageViewHeight;
}
@end
