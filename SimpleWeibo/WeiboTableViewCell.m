//
//  WeiboTableViewCell.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/22.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "WeiboTableViewCell.h"
#import "SJStatusView.h"
#import <Masonry/Masonry.h>


@interface WeiboTableViewCell ()
@property(nonatomic, strong) UIButton *repostButton;
@property(nonatomic, strong) UIButton *commentsButton;
@property(nonatomic, strong) UIButton *attitudeButton;

@property(nonatomic, strong) UIImageView *avatarImg;
@property(nonatomic, strong) UILabel *screenNameLab;
@property(nonatomic, strong) UILabel *creatAtLab;
@property(nonatomic, strong) UILabel *sourceLab;

@property(nonatomic, strong) SJStatusView *statusView;
@property(nonatomic, strong) SJStatusView *retweetedStatusView;

@property(nonatomic, strong) MASConstraint *statusBottomConstraint;
@property(nonatomic, strong) MASConstraint *retweetedStatusBottomConstraint;
@end

@implementation WeiboTableViewCell

+(CGFloat)getCellHeightWithStatus:(StatusModel*)status
{
    CGFloat height = 101.5;
    //50 + 30 + 20 + 1 + 0.5
    if(status.text){
        height += [self getHeightOfText:status.text];
    }

    if(status.pic_infos && !status.isRetweeted){
        height += [SJStatusView getStatusView:nil withPhotoModel:status.pic_infos isImageView:YES];
    }else if (status.page_info && !status.isRetweeted){
        height += [SJStatusView getStatusView:status.page_info withPhotoModel:nil isImageView:NO];
    }
    
    if(status.isRetweeted){
        if(status.retweeted_status.text){
            height += [self getHeightOfText:status.retweeted_status.text];
        }
        if(status.retweeted_status.pic_infos){
            height += [SJStatusView getStatusView:nil withPhotoModel:status.retweeted_status.pic_infos isImageView:YES];
        }else if (status.page_info){
            height += [SJStatusView getStatusView:status.page_info withPhotoModel:nil isImageView:NO];
        }
    }
    return height;
}


+(CGFloat)getHeightOfText:(NSString*)text
{
    CGRect frame = [text boundingRectWithSize:CGSizeMake(ScreenWidth - StatusContentLabelPadding * 2, 1000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:MainContentSize]} context:nil];
    return frame.size.height + 20;
}

+(NSAttributedString*)getAttributedString:(StatusModel*)status
{
    return Nil;
}



-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    self.repostButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.repostButton setImage:[UIImage imageNamed:@"timeline_icon_retweet"] forState:UIControlStateNormal];
    [self.repostButton setTitle:@"转发" forState:UIControlStateNormal];
    self.repostButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.repostButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.repostButton];
    [self.repostButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.height.mas_equalTo(30);
        make.width.equalTo(self.contentView.mas_width).multipliedBy(0.33).offset(-0.5);
    }];
    
    UIView *buttonSeparatorLeft = [[UIView alloc] init];
    [buttonSeparatorLeft setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
    [self.contentView addSubview:buttonSeparatorLeft];
    [buttonSeparatorLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.repostButton.mas_right);
        make.top.equalTo(self.repostButton.mas_top).offset(5);
        make.bottom.equalTo(self.repostButton.mas_bottom).offset(-5);
        make.width.mas_equalTo(1);
    }];
    
    self.commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentsButton setImage:[UIImage imageNamed:@"timeline_icon_comment"] forState:UIControlStateNormal];
    self.commentsButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.commentsButton setTitle:@"评论" forState:UIControlStateNormal];
    [self.commentsButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.commentsButton];
    [self.commentsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.repostButton.mas_bottom);
        make.top.equalTo(self.repostButton.mas_top);
        make.left.equalTo(buttonSeparatorLeft.mas_right);
        make.width.equalTo(self.contentView.mas_width).multipliedBy(0.33).offset(-0.5);
    }];
    
    UIView *buttonSeparatorRight = [[UIView alloc] init];
    [buttonSeparatorRight setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
    [self.contentView addSubview:buttonSeparatorRight];
    [buttonSeparatorRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.repostButton.mas_bottom).offset(-5);
        make.top.equalTo(self.repostButton.mas_top).offset(5);
        make.left.equalTo(self.commentsButton.mas_right);
        make.width.mas_equalTo(1);
    }];
    
    self.attitudeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.attitudeButton setImage:[UIImage imageNamed:@"timeline_icon_like_disable"] forState:UIControlStateNormal];
    self.attitudeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.attitudeButton setTitle:@"赞" forState:UIControlStateNormal];
    [self.attitudeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.attitudeButton];
    [self.attitudeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.repostButton.mas_bottom);
        make.top.equalTo(self.repostButton.mas_top);
        make.left.equalTo(buttonSeparatorRight.mas_right);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    UIView *buttonSeparatorTopLine = [[UIView alloc] init];
    [buttonSeparatorTopLine setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
    [self.contentView addSubview:buttonSeparatorTopLine];
    [buttonSeparatorTopLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.repostButton.mas_top);
        make.left.equalTo(self.contentView.mas_left).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
        make.height.mas_equalTo(1);
    }];
    
    self.avatarImg = [[UIImageView alloc] init];
    self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImg.layer.cornerRadius = 25.f;
    self.avatarImg.layer.masksToBounds = YES;
    [self.contentView addSubview:self.avatarImg];
    [self.avatarImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        //make.bottom.lessThanOrEqualTo(self.repostButton.mas_top).offset(-10);
        //make.bottom.equalTo(self.repostButton.mas_top).offset(-10).priority(MASLayoutPriorityDefaultHigh);
    }];
    
    self.screenNameLab = [[UILabel alloc] init];
    self.screenNameLab.textColor = [UIColor blackColor];
    self.screenNameLab.font = [UIFont systemFontOfSize:16];
    [self.screenNameLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.screenNameLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.contentView addSubview:self.screenNameLab];
    [self.screenNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.left.equalTo(self.avatarImg.mas_right).offset(10);
    }];
    
    self.creatAtLab = [[UILabel alloc] init];
    //self.creatAtLab.text = @"2016-10-10 10:10";
    self.creatAtLab.textColor = [UIColor grayColor];
    self.creatAtLab.font = [UIFont systemFontOfSize:12];
    [self.creatAtLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.creatAtLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.contentView addSubview:self.creatAtLab];
    [self.creatAtLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.screenNameLab.mas_bottom).offset(10);
        make.left.equalTo(self.avatarImg.mas_right).offset(10);
    }];
    
    self.sourceLab = [[UILabel alloc] init];
    //self.sourceLab.text = @"tweeter:the thing";
    self.sourceLab.textColor = [UIColor grayColor];
    self.sourceLab.font = [UIFont systemFontOfSize:12];
    [self.sourceLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.sourceLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.contentView addSubview:self.sourceLab];
    [self.sourceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.creatAtLab.mas_top);
        make.left.equalTo(self.creatAtLab.mas_right).offset(10);
    }];
    
    self.statusView = [[SJStatusView alloc] init];
    [self.contentView addSubview:self.statusView];
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatarImg.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView.mas_left);
        make.right.mas_equalTo(self.contentView.mas_right);
        self.statusBottomConstraint= make.bottom.mas_equalTo(buttonSeparatorTopLine.mas_top);
    }];
    
    self.retweetedStatusView = [[SJStatusView alloc] init];
    self.retweetedStatusView.backgroundColor = [UIColor colorWithRed:243 / 255.0 green:243 / 255.0 blue:243 / 255.0 alpha:1.0];
    self.retweetedStatusView.textLabel.backgroundColor = [UIColor clearColor];
    self.retweetedStatusView.hidden = YES;
    [self.contentView addSubview:self.retweetedStatusView];
    [self.retweetedStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.statusView.mas_bottom);
        make.left.mas_equalTo(self.contentView.mas_left);
        make.right.mas_equalTo(self.contentView.mas_right);
        self.retweetedStatusBottomConstraint = make.bottom.mas_equalTo(buttonSeparatorTopLine.mas_top);
    }];
    
}

-(void)setAvartarImageView:(NSURL*)imageURL{
    [self.avatarImg sd_setImageWithURL:imageURL];
}

-(void)setScreenNameLabText:(NSString*)text{
    self.screenNameLab.text = text;
}

-(void)setCreatAtLabText:(NSString*)text{
    self.creatAtLab.text = text;
}

-(void)setSourceLabText:(NSString*)text{
    self.sourceLab.text = text;
}


-(void)setStatusViewData:(StatusModel *)status
{
    [self setAvartarImageView:[NSURL URLWithString:status.user.profile_image_url]];
    [self setScreenNameLabText:status.user.screen_name];
    [self setCreatAtLabText:[status timeReversal:status.created_at]];
    [self setSourceLabText:[status validateHref:status.source]];
    self.statusView.textLabel.text = status.text;
    if(status.reposts_count <= 0){
        self.repostButton.titleLabel.text = @"转发";
    }else{
        self.repostButton.titleLabel.text = [NSString stringWithFormat: @"%d", status.reposts_count];
    }
    if(status.comments_count <= 0){
        self.commentsButton.titleLabel.text = @"评论";
    }else{
        self.commentsButton.titleLabel.text = [NSString stringWithFormat:@"%d", status.comments_count];
    }
    if(status.attitudes_count <= 0){
        self.attitudeButton.titleLabel.text = @"赞";
    }else{
        self.attitudeButton.titleLabel.text = [NSString stringWithFormat:@"%d", status.attitudes_count];
    }
    
    if(status.retweeted_status){
        NSString *retweeted_statusText = [NSString stringWithFormat:@"@%@:%@", status.retweeted_status.user.screen_name, status.retweeted_status.text];
        self.retweetedStatusView.textLabel.text = retweeted_statusText;
        [self.statusBottomConstraint uninstall];
        [self.retweetedStatusBottomConstraint install];
        self.retweetedStatusView.hidden = NO;
    }else{
        [self.statusBottomConstraint install];
        [self.retweetedStatusBottomConstraint uninstall];
        self.retweetedStatusView.hidden = YES;
    }
    if(status.pic_infos){
        [self.statusView setGridImageViewWithImages:status.pic_infos];
        [self.retweetedStatusView setGridImageViewWithImages:nil];
    }else if(status.retweeted_status.pic_infos){
        [self.statusView setGridImageViewWithImages:nil];
        [self.retweetedStatusView setGridImageViewWithImages:status.retweeted_status.pic_infos];
    }else if(status.page_info){
        if(status.retweeted_status){
            [self.retweetedStatusView setPageViewWithData:status.page_info];
            [self.statusView setPageViewWithData:nil];
        }else{
            [self.statusView setPageViewWithData:status.page_info];
            [self.retweetedStatusView setPageViewWithData:nil];
        }
    }else{
        [self.statusView setPageViewWithData:nil];
        [self.retweetedStatusView setPageViewWithData:nil];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
