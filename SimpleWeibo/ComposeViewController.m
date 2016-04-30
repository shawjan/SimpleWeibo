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

@interface ComposeViewController ()<PickPhotosCVCDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ComposePhotoCellDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet ComposePhotoGridView *imageGridView;
@property (strong, nonatomic) IBOutlet UILabel *warningLabel;
@property (strong, nonatomic) IBOutlet UITextView *composeTextView;
@property (strong, nonatomic) IBOutlet UIView *toolBarView;

@property(nonatomic, strong)PHFetchResult *fetchResults;
@property(nonatomic, strong)NSMutableArray *selections;
@property(nonatomic, strong) PHCachingImageManager *cachingImageManager;
@end

static CGSize ComposePhotoGridViewCellSize;
@implementation ComposeViewController

-(NSMutableArray *)selections{
    if(!_selections){
        _selections = [[NSMutableArray alloc] init];
    }
    return _selections;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChanged:) name:UITextViewTextDidBeginEditingNotification object:nil];
    self.composeTextView.delegate = self;
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
//    NSArray *layoutArray = [self.toolBarView constraints];
//    for (NSLayoutConstraint *layout in layoutArray) {
//        if([layout.identifier isEqualToString:@"ToolBarViewToBottom"]){
//            [NSLayoutConstraint deactivateConstraints:@[layout]];
//            break;
//        }
//    }
//    [self.toolBarView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.view.mas_bottom).offset(keyboardSize.height + frame.size.height);
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
//    NSArray *layoutArray = [self.toolBarView constraints];
//    for (NSLayoutConstraint *layout in layoutArray) {
//        if([layout.identifier isEqualToString:@"ToolBarViewToBottom"]){
//            [NSLayoutConstraint activateConstraints:@[layout]];
//            break;
//        }
//    }
//    [self.toolBarView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.view.mas_bottom).offset(50);
//    }];
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    CGRect frame = [text boundingRectWithSize:CGSizeMake(self.composeTextView.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0]} context:nil];
    if(frame.size.height + 70 > self.toolBarView.frame.origin.y){
        CGFloat offset = (frame.size.height + 70 - self.toolBarView.frame.origin.y);
        [self.composeTextView setContentOffset:CGPointMake(0, offset) animated:YES];
    }
    if([text length] > 140){
        self.warningLabel.hidden = NO;
        self.warningLabel.text = [NSString stringWithFormat:@"-%ld", [text length] - 140];
    }else{
        self.warningLabel.hidden = YES;
    }
    [self.view bringSubviewToFront:self.toolBarView];
}


-(PHCachingImageManager *)cachingImageManager
{
    if(!_cachingImageManager){
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}


-(void)composePhotoCellButtonClicked:(ComposePhotoGridViewCell *)cell
{
    NSIndexPath *indexPath = [self.imageGridView indexPathForCell:cell];
    [self.selections removeObjectAtIndex:indexPath.item];
    if(self.selections.count <2){
        [self.imageGridView reloadData];
    }else{
        [self.imageGridView deleteItemsAtIndexPaths:@[indexPath]];
    }
    [self adjustGridView:self.selections.count];
}

-(void)respondsToNextBtn:(NSArray *)selections
{
    [self.selections addObjectsFromArray:selections];
    
    CGFloat gridWidth = (ScreenWidth - 22) / 3;
    ComposePhotoGridViewCellSize = CGSizeMake(gridWidth, gridWidth);
    ((UICollectionViewFlowLayout*)self.imageGridView.collectionViewLayout).itemSize = ComposePhotoGridViewCellSize;
    
    [self adjustGridView:self.selections.count];
    

}

-(void)adjustGridView:(NSInteger)count
{
    if(count != 0 && count != 9){
        count += 1;
    }else if(self.selections.count > 9 || self.selections.count == 0){
        count = 0;
    }
    if(count == 0){
        self.imageGridView.hidden = YES;
    }else{
        self.imageGridView.hidden = NO;
        [self.imageGridView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(((count + 2) / 3) * ComposePhotoGridViewCellSize.height + 4);
        }];
        [self.imageGridView reloadData];
    }
}

-(void)showComposeVC
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PickPhotosCollectionVC *picPhotosCVC = [sb instantiateViewControllerWithIdentifier:@"Pick Photos CVC"];
    [picPhotosCVC.selections addObjectsFromArray: self.selections];
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
        [self.cachingImageManager requestImageForAsset:self.selections[indexPath.item]
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
                if(self.selections.count > 0){
                    [pickPhotoCVC.selections addObject:self.selections];
                }
            }
        }
        
    }
    
}


@end
