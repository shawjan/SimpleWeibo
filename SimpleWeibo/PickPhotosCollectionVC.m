//
//  PickPhotosCollectionVC.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/25.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "PickPhotosCollectionVC.h"
#import "PhotoCollectionViewCell.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVCaptureDevice.h>
#import "FullScreenImageView.h"

@interface PickPhotosCollectionVC ()<CollectionCellViewButtonClicked, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CheckStatusChangeObserver>

@property(nonatomic, strong)NSMutableArray *photos;
@property(nonatomic, strong)PHFetchResult *assetsFetchResults;
@property(nonatomic, strong)PHCachingImageManager *imageManager;
@property (nonatomic, assign)CGRect previousPreheatRect;
@end

NSString * const photoCVCIdentifier = @"PhotoCVCIdentifier";
static CGSize AssetGridThumbnailSize;

@implementation PickPhotosCollectionVC

-(PHCachingImageManager *)imageManager
{
    if(!_imageManager){
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

-(void)viewDidLoad
{
    self.collectionView.allowsMultipleSelection = YES;
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
    self.navigationItem.leftBarButtonItem = backBarItem;
    UIBarButtonItem *nextBarItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonClicked:)];
    nextBarItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = nextBarItem;
    self.navigationItem.title = @"发布微博";
    [self getPhotoCollection];
    
}

-(void)awakeFromNib
{
    if(self.collectionView.indexPathsForSelectedItems.count > 0){
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"下一步(%ld)", self.collectionView.indexPathsForSelectedItems.count];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.title = @"下一步";
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

-(void)nextButtonClicked:(id)sender
{
    
}

-(void)backButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPhotoCollection];
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if(authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied){
        NSLog(@"error");
    }
    
    CGFloat scale = ([UIScreen mainScreen].bounds.size.width - 4) / 3;
    AssetGridThumbnailSize = CGSizeMake(scale, scale);
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize = AssetGridThumbnailSize;
}

-(void)dealloc
{
    
}

-(void)getPhotoCollection
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
}

-(void)updateCellCheckButton:(BOOL)selected withIndexPath:(NSIndexPath*)indexPath
{
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if(!selected){
        if(self.collectionView.indexPathsForSelectedItems.count < 9){
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [cell updateCheckImage];
        }
        if(self.collectionView.indexPathsForSelectedItems.count > 0){
            self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"下一步(%ld)", self.collectionView.indexPathsForSelectedItems.count];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else{
            self.navigationItem.rightBarButtonItem.title = @"下一步";
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        NSLog(@"%ld", self.collectionView.indexPathsForSelectedItems.count);
        
    }else{
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [cell updateCheckImage];
        if(self.collectionView.indexPathsForSelectedItems.count > 1){
            self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"下一步(%ld)", self.collectionView.indexPathsForSelectedItems.count];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else{
            self.navigationItem.rightBarButtonItem.title = @"下一步";
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        NSLog(@"%ld", self.collectionView.indexPathsForSelectedItems.count);
    }
}

-(void)collectionCellViewButtonClicked:(id)sender
{
    if([sender isKindOfClass:[UIButton class]]){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:((UIButton*)sender).tag inSection:0];
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self updateCellCheckButton:cell.selected withIndexPath:indexPath];
    }
}

#pragma mark 

-(void)checkButtonStatusChangeObserver:(BOOL)selected withIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if(selected != cell.selected){
        [self updateCellCheckButton:!selected withIndexPath:indexPath];
    }
}

-(CGSize)targetSize{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGSize targetSize = CGSizeMake(size.width * scale, size.height * scale);
    return targetSize;
}

#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetsFetchResults.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoCVCIdentifier forIndexPath:indexPath];
    if(indexPath.item == 0){
        [cell setImage:[UIImage imageNamed:@"compose_photo_photograph"] withIndex:0];
    }else{
        [self.imageManager requestImageForAsset:self.assetsFetchResults[indexPath.item - 1]
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [cell setImage:result withIndex:indexPath.item];
        }];
    }
    cell.delegate = self;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if(indexPath.item != 0){
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        FullScreenImageView *imageView = [[FullScreenImageView alloc] initWithFrame:self.view.frame withSelected:cell.selected numberOfSelected:collectionView.indexPathsForSelectedItems.count withIndexPath:indexPath withType:FullScreenImageViewSelectableType];
        imageView.delegate = self;
        [self.view.window addSubview:imageView];
        [self.imageManager requestImageForAsset:self.assetsFetchResults[indexPath.item - 1]
                                     targetSize:[self targetSize]
                                    contentMode:PHImageContentModeAspectFit
                                        options:nil
                                  resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                      if(!result)
                                          return ;
                                            [imageView updateImage:result];
                                        }];
        NSLog(@"%@", NSStringFromCGSize([self targetSize]));
        //NSLog(@"%ld", self.collectionView.indexPathsForSelectedItems.count);
    }else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item != 0){
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
        FullScreenImageView *imageView = [[FullScreenImageView alloc] initWithFrame:self.view.frame withSelected:cell.selected numberOfSelected:collectionView.indexPathsForSelectedItems.count withIndexPath:indexPath withType:FullScreenImageViewSelectableType];
        imageView.delegate = self;
        [self.imageManager requestImageForAsset:self.assetsFetchResults[indexPath.item - 1]
                                     targetSize:self.view.frame.size
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                            [imageView updateImage:result];
                                        }];
        [self.view.window addSubview:imageView];
        NSLog(@"%ld", self.collectionView.indexPathsForSelectedItems.count);
    }else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

@end
