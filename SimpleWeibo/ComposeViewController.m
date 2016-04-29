//
//  ComposeViewController.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/20.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "ComposeViewController.h"
#import "ComposePhotoGridView.h"
#import "PickPhotosCollectionVC.h"
#import "PickPhotosCollectionVC.h"
#import <Masonry/Masonry.h>

@interface ComposeViewController ()<PickPhotosCVCDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ComposePhotoCellDelegate>
@property (strong, nonatomic) IBOutlet ComposePhotoGridView *imageGridView;
@property (strong, nonatomic) IBOutlet UILabel *warningLabel;
@property (strong, nonatomic) IBOutlet UITextView *composeTextView;
@property (strong, nonatomic) IBOutlet UIView *toolBarView;

@property(nonatomic, strong)PHFetchResult *fetchResults;
@property(nonatomic, strong)NSArray *selections;
@property(nonatomic, strong) PHCachingImageManager *cachingImageManager;
@end

static CGSize ComposePhotoGridViewCellSize;
@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChanged:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [self.composeTextView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [self.composeTextView removeObserver:self forKeyPath:@"text" context:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

-(void)textViewChanged:(NSNotification*)noti
{
    if([self.composeTextView.text isEqualToString:@"分享新鲜事..."]){
        self.composeTextView.text = @"";
        self.composeTextView.textColor = [UIColor blackColor];
    }else if([self.composeTextView.text isEqualToString:@""]){
        self.composeTextView.text = @"分享新鲜事...";
        self.composeTextView.textColor = [UIColor lightGrayColor];
    }
}

-(void)keyboardWillShow:(NSNotification*)noti
{
    NSDictionary *info = [noti userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //NSLog(@"didShow:%@ %@", NSStringFromCGSize(keyboardSize), info);
    CGRect frame = self.toolBarView.frame;
    frame.origin.y = self.view.frame.size.height - (keyboardSize.height + frame.size.height);
    self.toolBarView.frame = frame;
//    [UIView animateWithDuration:((NSNumber*)[info objectForKey:UIKeyboardAnimationCurveUserInfoKey]).doubleValue animations:^{
//        
//    }];
}

-(void)keyboardWillHide:(NSNotification*)noti
{
    CGRect frame = self.toolBarView.frame;
    //NSLog(@"didHide:%@", NSStringFromCGSize(keyboardSize));
    frame.origin.y = self.view.frame.size.height - (50 + frame.size.height);
    self.toolBarView.frame = frame;
//    [UIView animateWithDuration:((NSNumber*)[info objectForKey:UIKeyboardAnimationCurveUserInfoKey]).doubleValue animations:^{
//        self.toolBarView.frame = frame;
//    }];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([object isKindOfClass:[UITextView class]] && [keyPath isEqualToString:@"text"]){
        NSString *text = self.composeTextView.text;
        CGRect frame = [text boundingRectWithSize:CGSizeMake(self.composeTextView.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0]} context:nil];
        
    }
}

-(PHCachingImageManager *)cachingImageManager
{
    if(!_cachingImageManager){
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}


-(void)setSelections:(NSArray *)selections
{
    CGFloat gridWidth = (ScreenWidth - 22) / 3;
    ComposePhotoGridViewCellSize = CGSizeMake(gridWidth, gridWidth);
    ((UICollectionViewFlowLayout*)self.imageGridView.collectionViewLayout).itemSize = ComposePhotoGridViewCellSize;
    
    _selections = selections;
    NSInteger count = _selections.count;
    if(count != 0 && count != 9){
        count += 1;
    }else if(_selections.count > 9 || _selections.count == 0){
        count = 0;
    }
    if(count == 0){
        self.imageGridView.hidden = YES;
    }else{
        self.imageGridView.hidden = NO;
        [self.imageGridView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(((count + 2) / 3) * ComposePhotoGridViewCellSize.height + 4);
        }];
//        CGRect frame = self.imageGridView.frame;
//        frame.size.height = ((count + 2) / 3) * ComposePhotoGridViewCellSize.height;
//        self.imageGridView.frame = frame;
        [self.imageGridView reloadData];
    }
}

-(void)composePhotoCellButtonClicked:(ComposePhotoGridViewCell *)cell
{
    NSIndexPath *indexPath = [self.imageGridView indexPathForCell:cell];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.selections];
    [array removeObjectAtIndex:indexPath.item];
    self.selections = [array copy];
}

-(void)respondsToNextBtn:(PHFetchResult *)fetchResult withSelections:(NSArray *)selections
{
    self.fetchResults = fetchResult;
    self.selections = selections;
}

-(void)showComposeVC
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PickPhotosCollectionVC *picPhotosCVC = [sb instantiateViewControllerWithIdentifier:@"Pick Photos CVC"];
    picPhotosCVC.selections = self.selections;
    picPhotosCVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picPhotosCVC];
    [self presentViewController:nav animated:YES completion:nil];
//    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"Show PickPhotoCVC" source:self destination:nav];
//    [segue perform];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.selections.count;
    if(count != 0 && count != 9){
        count += 1;
    }else if(self.selections.count > 9){
        count = 0;
    }
    return count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ComposePhotoGridViewCell *cell = [self.imageGridView dequeueReusableCellWithReuseIdentifier:@"ComposeGridCellIdentifier" forIndexPath:indexPath];
    if(indexPath.item < self.selections.count){
        NSIndexPath *index = self.selections[indexPath.item];
        [self.cachingImageManager requestImageForAsset:self.fetchResults[index.item]
                                            targetSize:ComposePhotoGridViewCellSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                   [cell.cellImageView setImage:result];
                                               }];
        cell.cellDeleteButton.hidden = NO;
    }else{
        [cell.cellImageView setImage:[UIImage imageNamed:@"compose_pic_add"]];
        cell.cellDeleteButton.hidden = YES;
    }
    
    cell.delegate = self;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selections.count < indexPath.item + 1){
        [self showComposeVC];
    }else{
        NSArray *selectIndexPaths = [collectionView indexPathsForSelectedItems];
        [self.fetchResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isSelected = false;
            for(NSIndexPath *indexPath in selectIndexPaths){
                if (indexPath.item == idx) {
                    isSelected = true;
                    break;
                }
            }
            if(!isSelected){
                
            }
        }];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"Show PickPhotoCVC"]){
        if([segue.destinationViewController isKindOfClass:[UINavigationController class]]){
            UINavigationController *nav = segue.destinationViewController;
            if([nav.viewControllers[0] isKindOfClass:[PickPhotosCollectionVC class]]){
                PickPhotosCollectionVC *pickPhotoCVC = nav.viewControllers[0];
                pickPhotoCVC.delegate = self;
            }
        }
        
    }
    
}


@end
