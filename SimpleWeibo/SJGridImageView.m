//
//  SJGridImageView.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/23.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "SJGridImageView.h"
#import "SJImageUnitView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface SJGridImageView ()<SJImageUnitViewDelegate>

@property (nonatomic, strong) NSMutableArray *images;
@property(nonatomic, strong) NSMutableArray *srcImages;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) SJImageUnitView *oneHorizonView;
@property (nonatomic, strong) SJImageUnitView *oneVerticalView;

@end

#define MultiPhotoWidth (([UIScreen mainScreen].bounds.size.width - 20) / 3)
#define OneHorizonPhotoWidth (([UIScreen mainScreen].bounds.size.width - 20) * 0.7)
#define OneHorizonPhotoHeight (OneHorizonPhotoWidth / 4 * 3)
#define OneVerticalPhotoWidth (([UIScreen mainScreen].bounds.size.width - 20) * 0.5)
#define OneVerticalPhotoHeight (OneVerticalPhotoWidth / 3 * 4)
#define ImageURL @"url"
#define ImageHeight @"height"
#define ImageWidth @"width"

@implementation SJGridImageView

-(instancetype)init
{
    self = [super init];
    if(self){
        [self setupView];
    }
    return self;
}

-(NSMutableArray *)imageViews
{
    if(!_imageViews){
        _imageViews = [[NSMutableArray alloc] init];
    }
    return _imageViews;
}

-(void)setupView
{
    for(int row = 0; row < 3; ++row){
        for(int col = 0; col < 3; ++col){
            SJImageUnitView *imageUnitView = [[SJImageUnitView alloc] init];
            imageUnitView.backgroundColor = [UIColor whiteColor];
            imageUnitView.delegate = self;
            //imageUnitView.backgroundColor = [UIColor yellowColor];
            imageUnitView.imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageUnitView.imageView.clipsToBounds = YES;
            [self addSubview:imageUnitView];
            imageUnitView.hidden = YES;
            if(row == 0 && col == 0){
                [imageUnitView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.mas_left);
                    make.top.mas_equalTo(self.mas_top);
                    make.size.mas_equalTo(CGSizeMake(MultiPhotoWidth, MultiPhotoWidth));
                }];
            }else if(row == 1 && col == 0){
                SJImageUnitView *lastLevelView = self.imageViews[0];
                [imageUnitView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.mas_left);
                    make.top.mas_equalTo(lastLevelView.mas_bottom);
                    make.size.mas_equalTo(CGSizeMake(MultiPhotoWidth, MultiPhotoWidth));
                }];
            }else if(row == 2 && col == 0){
                SJImageUnitView *lastLevelView = self.imageViews[3];
                [imageUnitView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.mas_left);
                    make.top.mas_equalTo(lastLevelView.mas_bottom);
                    make.size.mas_equalTo(CGSizeMake(MultiPhotoWidth, MultiPhotoWidth));
                }];
            }else{
                SJImageUnitView *leftView = self.imageViews[row * 3 + col - 1];
                [imageUnitView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(leftView.mas_right);
                    make.top.mas_equalTo(leftView.mas_top);
                    make.size.mas_equalTo(CGSizeMake(MultiPhotoWidth, MultiPhotoWidth));
                }];
            }
            [self.imageViews addObject:imageUnitView];
        }
    }
    
    self.oneHorizonView = [[SJImageUnitView alloc] init];
    self.oneHorizonView.delegate = self;
    self.oneHorizonView.backgroundColor = [UIColor whiteColor];
    //self.oneHorizonView.backgroundColor = [UIColor redColor];
    self.oneHorizonView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.oneHorizonView.imageView.clipsToBounds = YES;
    [self addSubview:self.oneHorizonView];
    self.oneHorizonView.hidden = YES;
    [self.oneHorizonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.left.mas_equalTo(self.mas_left);
        make.size.mas_equalTo(CGSizeMake(OneHorizonPhotoWidth, OneHorizonPhotoHeight));
    }];
    
    self.oneVerticalView = [[SJImageUnitView alloc] init];
    self.oneHorizonView.delegate =self;
    self.oneVerticalView.backgroundColor = [UIColor whiteColor];
    self.oneVerticalView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.oneVerticalView.imageView.clipsToBounds = YES;
    [self addSubview:self.oneVerticalView];
    self.oneVerticalView.hidden = YES;
    [self.oneVerticalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.left.mas_equalTo(self.mas_left);
        make.size.mas_equalTo(CGSizeMake(OneVerticalPhotoWidth, OneVerticalPhotoHeight));
        //make.bottom.mas_equalTo(self.mas_bottom).priorityLow();
    }];
}

-(void)updateWithImages:(NSMutableArray*)images sourceImages:(NSMutableArray*)srcImages
{
    self.images = images;
    self.srcImages = srcImages;
    
    if(images.count == 1){
        CGFloat height = ((NSNumber*)images[0][ImageHeight]).floatValue;
        CGFloat width = ((NSNumber*)images[0][ImageWidth]).floatValue;
        if(height > width){
            //[self.oneVerticalView.imageView setImage:[self testImage]];
            NSString *imageStr = images[0][ImageURL];
            [self.oneVerticalView.imageView sd_setImageWithURL:[NSURL URLWithString:imageStr]];
            //NSLog(@"%@ %@", [NSURL URLWithString:images[0][ImageURL]], images[0][ImageURL]);
            self.oneHorizonView.hidden = YES;
            self.oneVerticalView.hidden = NO;
        }else{
            //[self.oneHorizonView.imageView setImage:[self testImage]];
            [self.oneHorizonView.imageView sd_setImageWithURL:[NSURL URLWithString:images[0][ImageURL]]];
            self.oneHorizonView.hidden = NO;
            self.oneVerticalView.hidden = YES;
        }
    }else{
        self.oneHorizonView.hidden = YES;
        self.oneVerticalView.hidden = YES;
    }
    
    for(int i = 0; i < self.imageViews.count; ++i){
        SJImageUnitView *imageView = self.imageViews[i];
        if(images.count == 1){
            imageView.hidden = YES;
        }else{
            if(images.count == 4){
                if(i == 0 || i == 1){
                    [imageView.imageView sd_setImageWithURL:[NSURL URLWithString:images[i][ImageURL]]];
                    //[imageView.imageView setImage:[self testImage]];
                    imageView.hidden = NO;
                }else if(i == 3 || i == 4){
                    [imageView.imageView sd_setImageWithURL:[NSURL URLWithString:images[i - 2][ImageURL]]];
                    //[imageView.imageView setImage:[self testImage]];
                    imageView.hidden = NO;
                }else{
                    imageView.hidden = YES;
                }
            }else{
                if(i < images.count){
                    [imageView.imageView sd_setImageWithURL:[NSURL URLWithString:images[i][ImageURL]]];
                    //[imageView.imageView setImage:[self testImage]];
                    imageView.hidden = NO;
                }else{
                    imageView.hidden = YES;
                }
            }
        }
    }
}

+(CGFloat)getGridImageViewHeightWithImages:(NSMutableArray*)images{
    NSInteger imageCount = images.count;
    CGFloat height = OneHorizonPhotoHeight;
    if(imageCount == 1){
        CGFloat imageHeight = ((NSNumber*)images[0][ImageHeight]).floatValue;
        CGFloat imageWidth = ((NSNumber*)images[0][ImageWidth]).floatValue;
        if (imageHeight > imageWidth) {
            height = OneVerticalPhotoHeight;
        }
    }else{
        height = ((imageCount + 2) / 3) * MultiPhotoWidth;
    }
    return height;
}

+(CGFloat)getGridImageViewHeightWithImageCount:(NSInteger)imageCount{
    CGFloat height = OneHorizonPhotoHeight;
    if(imageCount != 1){
        height = ((imageCount + 2) / 3) * MultiPhotoWidth;
    }
    return height;
}


-(UIImage *)testImage
{
    return [UIImage imageNamed:@"test.jpg"];
}


-(void)imageButtonClicked:(id)instance
{
    if([self.oneHorizonView isEqual:instance]){
        [[NSNotificationCenter defaultCenter] postNotificationName:RespondToCellButton object:@{ImageData : self.srcImages, WhichImage:[NSNumber numberWithInt:0]} userInfo:@{WhichType:ImageViewClicked}];
    }else if([self.oneVerticalView isEqual:instance]){
        [[NSNotificationCenter defaultCenter] postNotificationName:RespondToCellButton object:@{ImageData : self.srcImages, WhichImage:[NSNumber numberWithInt:0]}  userInfo:@{WhichType:ImageViewClicked}];
    }else{
        for(int i = 0; i < self.imageViews.count; ++i){
            if([self.imageViews[i] isEqual:instance]){
                [[NSNotificationCenter defaultCenter] postNotificationName:RespondToCellButton object:@{ImageData : self.srcImages, WhichImage:[NSNumber numberWithInt:i]}  userInfo:@{WhichType:ImageViewClicked}];
            }
        }
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
