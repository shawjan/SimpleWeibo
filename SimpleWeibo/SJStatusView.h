//
//  SJStatusView.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/22.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJGridImageView.h"
#import "PhotoModel.h"

@interface SJStatusView : UIView

@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, strong) SJGridImageView *imageGridView;
@property(nonatomic, strong) UIView *testView;

-(void)setGridImageViewWithImages:(PhotoModel*)images;
-(void)setMovieViewWithDictionary:(NSDictionary*)dictionary;
-(void)setPageViewWithData:(NSDictionary *)pageInfos;
+(CGFloat)getStatusView:(NSDictionary*)infos withPhotoModel:(PhotoModel*)images isImageView:(BOOL)isImageView;
@end
