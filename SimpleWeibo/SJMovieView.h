//
//  SJMovieView.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/26.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJMovieView : UIView

@property(nonatomic, strong)NSURL *videoURL;
@property(nonatomic, strong) NSDictionary *mediaInfo;

+(CGFloat)getMovieViewHeight;

@end
