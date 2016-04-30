//
//  PhotoCollectionViewCell.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/25.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotoCollectionViewCell;

@protocol CollectionCellViewButtonClicked <NSObject>

-(void)collectionCellViewButtonClicked:(PhotoCollectionViewCell*)cell;

@end

@interface PhotoCollectionViewCell : UICollectionViewCell

@property(nonatomic, assign) id <CollectionCellViewButtonClicked> delegate;

-(void)setImage:(UIImage*)image withIndex:(NSUInteger)cellIndex;
-(void)updateCheckImage;
@end

