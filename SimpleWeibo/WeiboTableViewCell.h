//
//  WeiboTableViewCell.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/22.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusModel.h"

@interface WeiboTableViewCell : UITableViewCell

-(void)setStatusViewData:(StatusModel *)status;
+(CGFloat)getCellHeightWithStatus:(StatusModel*)status;


//-(void)setAvartarImageView:(NSURL*)imageURL;
//
//-(void)setScreenNameLabText:(NSString*)text;
//
//-(void)setCreatAtLabText:(NSString*)text;
//
//-(void)setSourceLabText:(NSString*)text;

@end
