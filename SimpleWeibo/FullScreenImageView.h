//
//  FullScreenImageView.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/26.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickPhotosCollectionVC.h"

NS_ENUM(NSInteger, FullScreenImageViewType){
    FullScreenImageViewNoneType = 0,
    FullScreenImageViewSelectableType = 1,
};

@protocol CheckStatusChangeObserver <NSObject>

-(void)checkButtonStatusChangeObserver:(BOOL)selected withIndexPath:(NSIndexPath*)indexPath;

@end

@interface FullScreenImageView : UIView

@property(nonatomic, assign) id <CheckStatusChangeObserver> delegate;

-(instancetype)initWithFrame:(CGRect)frame withSelected:(BOOL)selected numberOfSelected:(NSInteger)selectedNum withIndexPath:(NSIndexPath*)indexPath withType:(enum FullScreenImageViewType)viewType parentVC:(id)pvc;
-(instancetype)initWithFrame:(CGRect)frame withType:(enum FullScreenImageViewType)viewType;

-(void)updateImage:(UIImage*)image;

@end
