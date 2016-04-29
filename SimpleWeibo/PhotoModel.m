//
//  PhotoModel.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/24.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "PhotoModel.h"

#define Weibo_LargePhoto @"large"
#define Weibo_ThumbnailPhoto @"thumbnail"

@implementation PhotoModel


//-(NSMutableArray *)images
//{
//    if(!_images){
//        _images = [[NSMutableArray alloc] init];
//    }
//    return _images;
//}
//
//-(NSMutableArray *)srcImages
//{
//    if (!_srcImages) {
//        _srcImages = [[NSMutableArray alloc] init];
//    }
//    return _srcImages;
//}

-(void)filterPhotoSize:(NSDictionary*)dic
{
    if([dic isKindOfClass:[NSDictionary class]]){
        NSMutableArray *images = [[NSMutableArray alloc] init];
        NSMutableArray *srcImages = [[NSMutableArray alloc] init];
        NSArray *keyArray = [dic allKeys];
        for (NSString *key in keyArray) {
            NSDictionary *photoDic = dic[key];
            if([photoDic isKindOfClass:[NSDictionary class]] && photoDic != nil){
                [images addObject:photoDic[Weibo_ThumbnailPhoto]];
                [srcImages addObject:photoDic[Weibo_LargePhoto]];
            }
        }
        [self setValue:images forKey:@"images"];
        [self setValue:srcImages forKey:@"srcImages"];
    }
    
}

@end

