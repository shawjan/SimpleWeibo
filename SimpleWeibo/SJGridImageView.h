//
//  SJGridImageView.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/23.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SJGridImageView : UIView

-(void)updateWithImages:(NSMutableArray*)images sourceImages:(NSMutableArray*)srcImages;
+(CGFloat)getGridImageViewHeightWithImages:(NSMutableArray*)images;
+(CGFloat)getGridImageViewHeightWithImageCount:(NSInteger)imageCount;

@end
