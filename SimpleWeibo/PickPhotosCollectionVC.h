//
//  PickPhotosCollectionVC.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/25.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVCaptureDevice.h>
@protocol PickPhotosCVCDelegate <NSObject>

-(void)respondsToNextBtn:(PHFetchResult*)fetchResult withSelections:(NSArray*)selections;

@end


@interface PickPhotosCollectionVC : UICollectionViewController
@property(nonatomic, strong)NSArray *selections;
@property(nonatomic, strong)PHFetchResult *assetsFetchResults;
@property(nonatomic, assign) id<PickPhotosCVCDelegate> delegate;
@end
