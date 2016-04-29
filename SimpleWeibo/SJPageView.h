//
//  SJPageView.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/26.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJPageView : UIView

@property(nonatomic, strong)NSDictionary *pageInfo;

+(CGFloat)getHeightOfSJPageView;

@end
