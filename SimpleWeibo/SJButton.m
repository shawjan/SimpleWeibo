//
//  SJButton.m
//  SimpleWeibo
//
//  Created by shawjan on 16/5/2.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "SJButton.h"
#import <Masonry/Masonry.h>

@implementation SJButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

-(void)setupView
{
    self.buttonImg = [[UIImageView alloc] init];
    [self addSubview:self.buttonImg];
    [self.buttonImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(TimelineButtonWidth / 4);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(TimelineButtonHeight * 0.5, TimelineButtonHeight * 0.5));
    }];
    
    self.buttonLabel = [[UILabel alloc] init];
    self.buttonLabel.numberOfLines = 1;
    self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    self.buttonLabel.textColor = [UIColor grayColor];
    self.buttonLabel.font = [UIFont systemFontOfSize:13];
    [self.buttonLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.buttonLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self addSubview:self.buttonLabel];
    [self.buttonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.buttonImg.mas_right).offset(5);
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
