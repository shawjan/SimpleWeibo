//
//  FullScreenImageView.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/26.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "FullScreenImageView.h"
#import <Masonry/Masonry.h>

@interface FullScreenImageView()
@property(nonatomic, strong) UIImageView *checkImageView;
@property(nonatomic, strong) UIButton *checkButton;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, assign) enum FullScreenImageViewType viewType;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic, strong) NSIndexPath *indexPath;
@property(nonatomic, assign) NSInteger selectedNum;
@end

@implementation FullScreenImageView

-(instancetype)initWithFrame:(CGRect)frame withSelected:(BOOL)selected numberOfSelected:(NSInteger)selectedNum withIndexPath:(NSIndexPath*)indexPath withType:(enum FullScreenImageViewType)viewType{
    self = [super initWithFrame:frame];
    if(self){
        self.selectedNum = selectedNum;
        self.viewType = viewType;
        self.selected = selected;
        self.indexPath = indexPath;
        [self setupView];
    }
    return self;
}

-(void)setupView
{
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerRespond:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    if(self.viewType == FullScreenImageViewSelectableType){
        self.checkImageView = [[UIImageView alloc] init];
        [self addSubview:self.checkImageView];
         CGFloat buttonWith = self.frame.size.width * 0.15;
        [self.checkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(buttonWith * 2);
            make.right.mas_equalTo(self.mas_right).offset(-buttonWith);
            make.size.mas_equalTo(CGSizeMake(buttonWith, buttonWith));
        }];
        if(!self.selected){
            self.checkImageView.image = [UIImage imageNamed:@"compose_guide_check_box_default"];
        }else{
            self.checkImageView.image = [UIImage imageNamed:@"compose_guide_check_box_right"];
        }
        
        self.checkButton = [[UIButton alloc] init];
        [self addSubview: self.checkButton];
        [self.checkButton addTarget:self action:@selector(checkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(buttonWith, buttonWith));
            make.centerX.mas_equalTo(self.checkImageView.mas_centerX);
            make.centerY.mas_equalTo(self.checkImageView.mas_centerY);
        }];
    }
}

-(void)updateImage:(UIImage *)image
{
    self.imageView.image = image;
}

-(void)checkButtonClicked:(id)sender
{
    self.selected = !self.selected;
    if(!self.selected){
        self.checkImageView.image = [UIImage imageNamed:@"compose_guide_check_box_default"];
    }else{
        if(self.selectedNum < 9){
            self.checkImageView.image = [UIImage imageNamed:@"compose_guide_check_box_right"];
        }
    }
}

-(void)tapGestureRecognizerRespond:(id)sender
{
    if([self.delegate respondsToSelector:@selector(checkButtonStatusChangeObserver: withIndexPath:)]){
        [self.delegate checkButtonStatusChangeObserver:self.selected withIndexPath:self.indexPath];
    }
    [self removeFromSuperview];
}

@end
