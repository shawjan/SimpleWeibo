//
//  PhotoModel.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/24.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSInteger, PicInfoType){
    PicInfoPhotosType,
    PicInfoMovieType,
    PicInfoPageType,
};

@interface PhotoModel : NSObject

@property(nonatomic, strong) NSMutableArray *images;
@property(nonatomic, strong) NSMutableArray *srcImages;
@property(nonatomic, strong) NSDictionary *pic_infos;
@property(nonatomic, assign) enum PicInfoType picInfoType;
-(void)filterPhotoSize:(NSDictionary*)dic;

@end
