//
//  StatusModel.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/23.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "StatusModel.h"
#import <objc/runtime.h>


#define Weibo_User @"user"
#define Weibo_RetweetedStatus @"retweeted_status"
#define Weibo_PicInfo @"pic_infos"
#define Weibo_Type @"type"
#define Weibo_ObjectType @"object_type"
#define Weibo_PageInfo @"page_info"

@implementation StatusModel

+(NSMutableArray*)jsonToStatusModelArray:(NSMutableArray*)statuses;
{
    NSMutableArray *array = [NSMutableArray array];
    
    for(NSDictionary *dic in statuses){
        StatusModel *status = [self jsonToStatusModel:dic];
        [array addObject:status];
    }
    return array;
}

+(StatusModel*)jsonToStatusModel:(NSDictionary*)status
{
    StatusModel *statusModel = [[StatusModel alloc] init];
    if([status isKindOfClass:[NSDictionary class]]){
        NSArray *keyArray = [status allKeys];
        for(NSString *key in keyArray){
            if([status[key] isKindOfClass:[UserModel class]]){
                UserModel *userModel = [self jsonToUserModel:status[key]];
                [statusModel setValue:userModel forKey:key];
            }else{
                [statusModel setValue:status[key] forKey:key];
            }
        }
    }
    
    
    return statusModel;
}

+(UserModel*)jsonToUserModel:(NSDictionary*)user
{
    UserModel *userModel = [[UserModel alloc] init];
    if([user isKindOfClass:[UserModel class]]){
        NSArray *keyArray = [user allKeys];
        for(NSString *key in keyArray){
            [userModel setValue:user[key] forKey:key];
        }
    }
    return userModel;
}

+(NSArray*)propertyKeys
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableArray *keyArray = [[NSMutableArray alloc] initWithCapacity:outCount];
    for(i = 0; i < outCount; ++i){
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [keyArray addObject:propertyName];
    }
    free(properties);
    return [keyArray copy];
}

-(BOOL)reflectDataFromOtherObject:(NSObject*)dataSource{
    BOOL ret = NO;
    self.height = 0;
    self.sourceType = StatusModelNoneType;
    self.isRetweeted = NO;
    for(NSString *key in [StatusModel propertyKeys]){
        if([dataSource isKindOfClass:[NSDictionary class]]){
            ret = [dataSource valueForKey:key] == nil ? NO : YES;
        }else{
            ret = [dataSource respondsToSelector:NSSelectorFromString(key)];
        }
        if(ret){
            id propertyValue = [dataSource valueForKey:key];
            if(![propertyValue isKindOfClass:[NSNull class]] && propertyValue != nil){
                if([key isEqualToString:Weibo_User] && [propertyValue isKindOfClass:[NSDictionary class]]){
                    UserModel *user = [[UserModel alloc] init];
                    [user reflectDataFromOtherObject:propertyValue];
                    [self setValue:user forKey:key];
                }else if([key isEqualToString:Weibo_RetweetedStatus] && [propertyValue isKindOfClass:[NSDictionary class]]){
                    StatusModel *status = [[StatusModel alloc] init];
                    [status reflectDataFromOtherObject:propertyValue];
                    [self setValue: status forKey:key];
                    self.isRetweeted = YES;
                }else if([key isEqualToString:Weibo_PicInfo] && [propertyValue isKindOfClass:[NSDictionary class]]){
                    //StatusModel *status = [[StatusModel alloc] init];
                    PhotoModel *photos = [[PhotoModel alloc] init];
                    [photos filterPhotoSize:propertyValue];
                    [self setValue:photos forKey:key];
                    self.pic_infos.picInfoType = PicInfoPhotosType;
                    if(photos){
                        self.sourceType = StatusModelImageType;
                    }
                    //NSLog(@"%@ %@", photos.images, photos.srcImages);
                }else{
                    if([key isEqualToString:Weibo_PageInfo] && ![propertyValue isKindOfClass:[NSNull class]] && propertyValue != nil){
                        self.sourceType = StatusModelPageType;
                    }
                    [self  setValue:propertyValue forKey:key];
                }
            }
        }
    }
    //NSLog(@"%@ %@", self.pic_infos.images, self.pic_infos.srcImages);
    return ret;
}

-(NSString*)timeReversal:(NSString*)dateString
{
    NSString *localDateString = nil;
    NSDateFormatter *zoneFormatter = [NSDateFormatter new];
    zoneFormatter.dateFormat = @"EEE MMM dd HH:mm:ss z yyyy";
    zoneFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate * date = [zoneFormatter dateFromString:dateString];
    NSTimeInterval distance = [[NSDate date] timeIntervalSinceDate:date];
    
    if(distance < 0){
        distance = 0;
    }
    
    if(distance < 60){
        localDateString = [NSString stringWithFormat:@"%.0f%@", distance, @"秒钟前"];
    }else if(distance < 60 * 60){
        distance = distance / 60;
        localDateString = [NSString stringWithFormat:@"%.0f%@", distance, @"分钟前"];
    }else if(distance < 60 * 60 * 24){
        distance = distance / 60 / 60;
        localDateString = [NSString stringWithFormat:@"%.0f%@", distance, @"小时前"];
    }else if(distance < 60 * 60 * 24 * 7){
        distance = distance / 60 / 60 / 24;
        localDateString = [NSString stringWithFormat:@"%.0f%@", distance, @"天前"];
    }else{
        NSDateFormatter * newFormatter = [[NSDateFormatter alloc] init];
        [newFormatter setDateStyle:NSDateFormatterMediumStyle];
        [newFormatter setTimeStyle:NSDateFormatterShortStyle];
        [newFormatter setDateFormat:@"YY-MM-dd"];
        localDateString = [newFormatter stringFromDate:date];
    }
    
    return localDateString;
}

-(NSString *)validateHref:(NSString*)string
{
    if(!string.length){
        return @"";
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=.*?>(.*?)</a>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *resultStr = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"$1"];
    resultStr = [NSString stringWithFormat:@"来自 %@", resultStr];
    return resultStr;
}

@end
