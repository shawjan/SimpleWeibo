//
//  StatusModel.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/23.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "PhotoModel.h"

NS_ENUM(NSInteger, StatusModelType){
    StatusModelNoneType,
    StatusModelImageType,
    StatusModelPageType,
};

@interface StatusModel : NSObject

@property(nonatomic, strong) UserModel *user;
@property(nonatomic, strong) NSString *created_at;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) NSString *source;
@property(nonatomic, assign) BOOL truncated;
@property(nonatomic, assign) int reposts_count;
@property(nonatomic, assign) int comments_count;
@property(nonatomic, assign) int attitudes_count;
@property(nonatomic, strong) StatusModel *retweeted_status;
@property(nonatomic, strong) PhotoModel *pic_infos;
@property(nonatomic, strong) NSDictionary *page_info;
@property(nonatomic, assign) enum StatusModelType sourceType;
@property(nonatomic, assign) float height;
@property(nonatomic, strong) NSAttributedString *attributedString;
@property(nonatomic, assign) BOOL isRetweeted;

+(NSMutableArray*)jsonToStatusModelArray:(NSMutableArray*)statuses;
//+(StatusModel*)jsonToStatusModel:(NSDictionary*)status;
//+(UserModel*)jsonToUserModel:(NSDictionary*)user;
-(BOOL)reflectDataFromOtherObject:(NSObject*)dataSource;
-(NSString*)timeReversal:(NSString*)dateString;
-(NSString *)validateHref:(NSString*)string;
//+(NSArray*)propertyKeys;
@end
