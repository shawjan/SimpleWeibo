//
//  UserModel.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/23.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "UserModel.h"
#import <objc/runtime.h>

@implementation UserModel

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
    for(NSString *key in [UserModel propertyKeys]){
        if([dataSource isKindOfClass:[NSDictionary class]]){
            ret = [dataSource valueForKey:key] == nil ? NO : YES;
        }else{
            ret = [dataSource respondsToSelector:NSSelectorFromString(key)];
        }
        if(ret){
            id propertyValue = [dataSource valueForKey:key];
            if(![propertyValue isKindOfClass:[NSNull class]] && propertyValue != nil){
                [self  setValue:propertyValue forKey:key];
            }
        }
    }
    return ret;
}

@end
