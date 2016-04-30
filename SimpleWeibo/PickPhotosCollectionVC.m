//
//  PickPhotosCollectionVC.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/25.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "PickPhotosCollectionVC.h"
#import "PhotoCollectionViewCell.h"
#import "ComposePhotoGridView.h"

#import "FullScreenImageView.h"

@interface PickPhotosCollectionVC ()<CollectionCellViewButtonClicked, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CheckStatusChangeObserver, PHPhotoLibraryChangeObserver>


@property(nonatomic, strong)PHCachingImageManager *imageManager;
@property (nonatomic, assign)CGRect previousPreheatRect;
@property(nonatomic, assign) BOOL isFromPickerView;
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

-(NSMutableArray *)selections
{
    if(!_selections){
        _selections = [[NSMutableArray alloc] init];
    }
    return _selections;
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

-(void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
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
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    [self getPhotoCollection];
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if(authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied){
        NSLog(@"error");
    }
    
    AssetGridThumbnailSize = CGSizeMake(GridWidth, GridWidth);
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize = AssetGridThumbnailSize;
    if(self.isFromPickerView){
        
        self.isFromPickerView = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)nextButtonClicked:(id)sender
{
    if([self.delegate respondsToSelector:@selector(respondsToNextBtn:)]){
        NSMutableArray *array = [NSMutableArray array];
        for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems){
            [array addObject:self.assetsFetchResults[indexPath.item]];
        }
        [self.delegate respondsToNextBtn:array];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)backButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateSelections
{
    for (int i = 0; i < self.selections.count; ++i) {
        if([self.assetsFetchResults containsObject:self.selections[i]]){
            NSUInteger index = [self.assetsFetchResults indexOfObject:self.selections[i]];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self updateCellCheckButton:NO withIndexPath:indexPath];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateSelections];
}

-(void)getPhotoCollection
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    [self.collectionView reloadData];
}

-(void)updateCellCheckButton:(BOOL)selected withIndexPath:(NSIndexPath*)indexPath
{
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if(!selected){
        if(self.collectionView.indexPathsForSelectedItems.count < 9){
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [cell updateCheckImage];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"只能够选择9张图" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:alertAction];
            [self presentViewController:alert animated:YES completion:nil];
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

-(void)collectionCellViewButtonClicked:(PhotoCollectionViewCell*)cell
{
    if([cell isKindOfClass:[PhotoCollectionViewCell class]]){
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
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
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGSize targetSize = CGSizeMake(size.width * screenScale, size.height * screenScale);
    return targetSize;
}

#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    originalImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    if(editedImage){
        imageToSave = editedImage;
    }else{
        imageToSave = originalImage;
    }
    
    //UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:imageToSave];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(!success){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"相片保存失败" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:alertAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    //[self dismissViewControllerAnimated:YES completion:nil];

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)photoLibraryDidChange:(PHChange *)changeInstance
{
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    
    if(collectionChanges == nil)
        return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        UICollectionView *collectionView = self.collectionView;
        if(![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]){
            [collectionView reloadData];
        }else{
            [collectionView performBatchUpdates:^{
                NSIndexSet * removedIndexes = [collectionChanges removedIndexes];
                if([removedIndexes count] > 0){
                    [collectionView deleteItemsAtIndexPaths:[self arrayFromIndexSet:removedIndexes]];
                }
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if([insertedIndexes count] > 0){
                    NSMutableArray *array = [NSMutableArray array];
                    [insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        [array addObject:[NSIndexPath indexPathForItem:idx+1 inSection:0]];
                    }];
                    [collectionView insertItemsAtIndexPaths:array];
                    self.isFromPickerView = YES;
                }
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if([changedIndexes count] > 0){
                    [collectionView reloadItemsAtIndexPaths:[self arrayFromIndexSet:changedIndexes]];
                }
            } completion:^(BOOL finished){
                if(finished){
                    [self updateCellCheckButton:NO withIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
                    //[self nextButtonClicked:nil];
                }
            }];
        }
    });
}

-(NSArray*)arrayFromIndexSet:(NSIndexSet*)indexSet
{
    NSMutableArray *array = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }];
    return array;
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
    }else if(collectionView.indexPathsForSelectedItems.count < 9){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"只能够选择9张图" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:alertAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item != 0 ){
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
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        picker.allowsEditing = NO;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

@end
