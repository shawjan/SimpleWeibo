//
//  SJImageUnitView.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/23.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJImageUnitView;
@protocol SJImageUnitViewDelegate <NSObject>

-(void)imageButtonClicked:(id)instance;

@end

@interface SJImageUnitView : UIView

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIButton *imageButton;
@property(nonatomic, assign) id<SJImageUnitViewDelegate>delegate;

@end
