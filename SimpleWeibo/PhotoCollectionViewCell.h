//
//  PhotoCollectionViewCell.h
//  SimpleWeibo
//
//  Created by shawjan on 16/4/25.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CollectionCellViewButtonClicked <NSObject>

-(void)collectionCellViewButtonClicked:(id)sender;

@end

@interface PhotoCollectionViewCell : UICollectionViewCell

@property(nonatomic, assign) id <CollectionCellViewButtonClicked> delegate;

-(void)setImage:(UIImage*)image withIndex:(NSUInteger)cellIndex;
-(void)updateCheckImage;
@end

