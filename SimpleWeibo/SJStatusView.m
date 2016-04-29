//
//  SJStatusView.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/22.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "SJStatusView.h"
#import <Masonry/Masonry.h>
#import "SJMovieView.h"
#import "SJPageView.h"

@interface SJStatusView ()

@property(nonatomic, strong) MASConstraint *gridImageBottomConstraint;
@property(nonatomic, strong) MASConstraint *pageViewBottomConstraint;
@property(nonatomic, strong) MASConstraint *movieViewBottomConstraint;
@property(nonatomic, strong) SJMovieView *movieView;
@property(nonatomic, strong) SJPageView *pageView;

@end

@implementation SJStatusView

#define imageGridViewWidth [SJGridImageView getGridImageViewHeightWithImageCount:9]

-(instancetype)init
{
    self = [super init];
    if(self){
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    self.imageGridView = [[SJGridImageView alloc] init];
    //self.imageGridView.backgroundColor = [UIColor blueColor];
    [self addSubview:self.imageGridView];
    self.imageGridView.hidden = YES;
    [self.imageGridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        make.left.mas_equalTo(self.mas_left).offset(10);
        //self.gridImageViewRightConstraint = make.right.mas_equalTo(self.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(0, 0));
        //NSLog(@"%f", imageGridViewHeight);
    }];
    
    self.movieView = [[SJMovieView alloc] init];
    [self addSubview:self.movieView];
    
    CGFloat height = [SJMovieView getMovieViewHeight];
    [self.movieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake(height, height));
    }];
    self.movieView.hidden = YES;
    
    self.pageView = [[SJPageView alloc] init];
    [self addSubview:self.pageView];
    height = [SJPageView getHeightOfSJPageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake(height, height));
    }];
    self.pageView.hidden = YES;

//    
//    self.testView = [[UIView alloc] init];
//    self.testView.backgroundColor = [UIColor blackColor];
//    [self addSubview:self.testView];
//    [self.testView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
//        make.left.mas_equalTo(self.mas_left).offset(10);
//        make.size.mas_equalTo(CGSizeMake(imageGridViewHeight, 30));
//    }];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:MainContentSize];
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //[self.textLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    //[self.textLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(10);
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.right.mas_equalTo(self.mas_right).offset(-10);
        self.gridImageBottomConstraint = make.bottom.mas_equalTo(self.imageGridView.mas_top).priorityLow();
        self.pageViewBottomConstraint = make.bottom.mas_equalTo(self.pageView.mas_top).priorityLow();
        self.movieViewBottomConstraint = make.bottom.mas_equalTo(self.movieView.mas_top).priorityLow();
    }];
}

-(void)setGridImageViewWithImages:(PhotoModel*)images{
    [self.gridImageBottomConstraint install];
    [self.movieViewBottomConstraint uninstall];
    [self.pageViewBottomConstraint uninstall];
    if([images isKindOfClass:[NSNull class]] || images == nil || images.images.count == 0){
        //[self.gridImageViewSizeConstraint uninstall];
        [self.imageGridView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
            make.left.mas_equalTo(self.mas_left).offset(10);
            //self.gridImageViewRightConstraint = make.right.mas_equalTo(self.mas_right).offset(-10);
            make.size.mas_equalTo(CGSizeMake(0, 0));
            //NSLog(@"%f", imageGridViewHeight);
        }];
        self.imageGridView.hidden = YES;
        //self.testView.hidden = YES;
    }else if(images.images.count == 1 ){
        CGFloat gridViewHeight = [SJGridImageView getGridImageViewHeightWithImages:images.images];
        [self.imageGridView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
            make.left.mas_equalTo(self.mas_left).offset(10);
            //make.right.mas_equalTo(self.mas_right).offset(-10);
            make.size.mas_equalTo(CGSizeMake(imageGridViewWidth,gridViewHeight));
        }];
        [self.imageGridView updateWithImages:images.images sourceImages:images.srcImages];
        //[self.gridImageViewRightConstraint install];
        //[self.gridImageViewSizeConstraint uninstall];
        self.imageGridView.hidden = NO;
        //self.testView.hidden = NO;
    }else{
        CGFloat gridViewHeight = [SJGridImageView getGridImageViewHeightWithImages:images.images];
        [self.imageGridView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
            make.left.mas_equalTo(self.mas_left).offset(10);
            //make.right.mas_equalTo(self.mas_right).offset(-10);
            make.size.mas_equalTo(CGSizeMake(imageGridViewWidth,gridViewHeight));
        }];
        [self.imageGridView updateWithImages:images.images sourceImages:images.srcImages];
        //[self.gridImageViewSizeConstraint install];
        //[self.gridImageViewSizeConstraint uninstall];
        self.imageGridView.hidden = NO;
        //self.testView.hidden = NO;
    }
    self.movieView.hidden = YES;
    self.pageView.hidden = YES;
}

-(void)setMovieViewWithDictionary:(NSDictionary*)dictionary
{
    [self.gridImageBottomConstraint uninstall];
    [self.movieViewBottomConstraint install];
    [self.pageViewBottomConstraint uninstall];
    [self.movieView setMediaInfo:dictionary];
    CGFloat height = [SJMovieView getMovieViewHeight];
    [self.movieView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake(height, height));
    }];
    self.pageView.hidden = YES;
    self.movieView.hidden = NO;
    //[self.movieView setVideoURL:[NSURL URLWithString:@""]];
}

-(void)setPageViewWithDictionary:(NSDictionary*)dictionary
{
    [self.gridImageBottomConstraint uninstall];
    [self.movieViewBottomConstraint uninstall];
    [self.pageViewBottomConstraint install];
    [self.pageView setPageInfo:dictionary];
    CGFloat height = [SJPageView getHeightOfSJPageView];
    [self.pageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake(height, height));
        make.top.mas_equalTo(self.textLabel.mas_bottom).priorityLow();
    }];
    self.pageView.hidden = NO;
    self.movieView.hidden = YES;
}

-(void)setPageViewWithData:(NSDictionary *)pageInfos
{
    [self.imageGridView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        make.left.mas_equalTo(self.mas_left).offset(10);
        //self.gridImageViewRightConstraint = make.right.mas_equalTo(self.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(0, 0));
        //NSLog(@"%f", imageGridViewHeight);
    }];
    self.imageGridView.hidden = YES;
    if(![pageInfos isKindOfClass:[NSNull class]] && pageInfos != nil){
        if(((NSString*)[pageInfos objectForKey:@"type"]).intValue == 11 && [[pageInfos objectForKey:@"object_type"] isEqualToString:@"video"]){
            [self setMovieViewWithDictionary:pageInfos];
        }else{
            [self setPageViewWithDictionary:pageInfos];
        }
    }else{
        [self.movieView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
            make.left.mas_equalTo(self.mas_left).offset(10);
            make.size.mas_equalTo(CGSizeMake(0, 0));
        }];
        [self.movieView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
            make.left.mas_equalTo(self.mas_left).offset(10);
            make.size.mas_equalTo(CGSizeMake(0, 0));
        }];
        self.pageView.hidden = YES;
        self.movieView.hidden = YES;
    }
}

+(CGFloat)getStatusView:(NSDictionary*)infos withPhotoModel:(PhotoModel*)images isImageView:(BOOL)isImageView
{
    CGFloat height = 0.0;
    if(isImageView){
        height += [SJGridImageView getGridImageViewHeightWithImages:images.images];
    }else{
        if(((NSString*)[infos objectForKey:@"type"]).intValue == 11 && [[infos objectForKey:@"object_type"] isEqualToString:@"video"]){
            height += [SJMovieView getMovieViewHeight];
        }else{
            height += [SJPageView getHeightOfSJPageView];
        }
    }
    return height;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
