//
//  UserModel.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/23.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property(nonatomic,strong) NSString * screen_name;
@property(nonatomic, strong)NSString * created_at;
@property(nonatomic, strong) NSString * profile_image_url;
@property(nonatomic, strong) NSString * source;
@property(nonatomic, strong) NSString *gender;

-(BOOL)reflectDataFromOtherObject:(NSObject*)dataSource;

@end
