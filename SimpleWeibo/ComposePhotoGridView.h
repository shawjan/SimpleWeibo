//
//  ComposePhotoGridView.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/29.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>


@interface ComposePhotoGridView : UICollectionView

@end

@class ComposePhotoGridViewCell;

@protocol ComposePhotoCellDelegate <NSObject>

-(void)composePhotoCellButtonClicked:(ComposePhotoGridViewCell*)cell;

@end

@interface ComposePhotoGridViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIButton *cellDeleteButton;
@property (strong, nonatomic) IBOutlet UIImageView *cellImageView;
@property(nonatomic, assign) id<ComposePhotoCellDelegate> delegate;

@end