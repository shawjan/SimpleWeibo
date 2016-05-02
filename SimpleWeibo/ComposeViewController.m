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
#import <WeiboSDK.h>
#import "FullScreenImageView.h"

@interface ComposeViewController ()<PickPhotosCVCDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ComposePhotoCellDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet ComposePhotoGridView *imageGridView;
@property (strong, nonatomic) IBOutlet UILabel *warningLabel;
@property (strong, nonatomic) IBOutlet UITextView *composeTextView;
@property (strong, nonatomic) IBOutlet UIView *toolBarView;
@property (strong, nonatomic) IBOutlet UIView *containtView;

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    //self.scrollView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self textViewChanged:nil];
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
#define gapBetweenToolBarAndTextView 5

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
    frame.origin.y = self.view.frame.size.height - frame.size.height;
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
//        make.bottom.mas_equalTo(self.view.mas_bottom);
//    }];
    [self textViewChanged:nil];
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    CGRect frame = [text boundingRectWithSize:CGSizeMake(self.composeTextView.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0]} context:nil];
    if(frame.size.height > self.composeTextView.frame.size.height - 40){
        CGFloat offset = (self.composeTextView.frame.size.height + self.composeTextView.frame.origin.y - self.toolBarView.frame.origin.y + 20);
        if(offset < -15){
            [self.scrollView setContentOffset:CGPointMake(0, -offset) animated:YES];
        }
    }
    if([text length] > 140){
        self.warningLabel.hidden = NO;
        self.warningLabel.text = [NSString stringWithFormat:@"-%ld", [text length] - 140];
    }else{
        self.warningLabel.hidden = YES;
    }
    //[self.view bringSubviewToFront:self.toolBarView];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]){
        if ([self.composeTextView isFirstResponder]) {
            [self.composeTextView resignFirstResponder];
        }
    }
    return YES;
}


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

-(void)uploadImageWithText:(NSData*)imageData
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", Weibo_PublicLink, @"statuses/upload.json"];
    [WBHttpRequest requestWithURL:urlStr
                       httpMethod:@"POST"
                           params:@{@"access_token":appDelegate.wbToken,
                                    @"status":self.composeTextView.text,
                                    @"pic": imageData}
                            queue:[NSOperationQueue mainQueue]
            withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                NSString *resultStr = nil;
                if(!error){
                    resultStr = @"发送成功！";
                    self.composeTextView.text = @"分享新鲜的事...";
                    self.composeTextView.textColor = [UIColor lightGrayColor];
                    if([self.composeTextView isFirstResponder]){
                        [self.composeTextView resignFirstResponder];
                    }
                    [self.selections removeAllObjects];
                    [self.imageGridView reloadData];
                }else{
                    resultStr = @"发送失败，请稍后再试";
                    NSLog(@"%ld :%@ - %@", error.code, error.domain, error.userInfo);
                }
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:resultStr preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                    if(error.code <= 21314 && error.code >= 21317){
                        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                        if([appDelegate.window.rootViewController isKindOfClass:[UITabBarController class]]){
                            [appDelegate.window.rootViewController performSegueWithIdentifier:@"Show LoginView" sender:self];
                        }
                    }
                }];
                [alert addAction:alertAction];
                [self presentViewController:alert animated:YES completion:nil];
            }];
}
- (IBAction)dismissViewCon:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)composeButtonClicked:(id)sender {
    if(![self.composeTextView.text isEqualToString:@""]){
        if([self.composeTextView.text length] > 140){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"内容太长，请删减！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:alertAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        if([self.selections count] > 0){
            //上传多张图片的接口需要授权，因此只上传一张图片
            [self.cachingImageManager requestImageForAsset:self.selections[0]
                                                targetSize:self.view.frame.size
                                               contentMode:PHImageContentModeAspectFill
                                                   options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                       NSData *imageData = UIImageJPEGRepresentation(result, 0.8);
                                                       [self uploadImageWithText:imageData];
            }];
            
        }else{
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSString *urlStr = [NSString stringWithFormat:@"%@%@", Weibo_PublicLink, @"statuses/update.json"];
            [WBHttpRequest requestWithURL:urlStr
                               httpMethod:@"POST"
                                   params:@{@"access_token":appDelegate.wbToken,
                                            @"status":self.composeTextView.text}
                                    queue:[NSOperationQueue mainQueue]
                    withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        NSString *resultStr = nil;
                        if(!error){
                            resultStr = @"发送成功！";
                            self.composeTextView.text = @"分享新鲜的事...";
                            self.composeTextView.textColor = [UIColor lightGrayColor];
                            if([self.composeTextView isFirstResponder]){
                                [self.composeTextView resignFirstResponder];
                            }
                            [self.selections removeAllObjects];
                            [self.imageGridView reloadData];
                        }else{
                            resultStr = @"发送失败，请稍后再试";
                        }
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:resultStr preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                            if(error.code <= 21314 && error.code >= 21317){
                                AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                if([appDelegate.window.rootViewController isKindOfClass:[UITabBarController class]]){
                                    [appDelegate.window.rootViewController performSegueWithIdentifier:@"Show LoginView" sender:self];
                                }
                            }
                        }];
                        [alert addAction:alertAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }];

        }
    }
    
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
    if(self.selections.count <1){
        [self.imageGridView reloadData];
    }else if(self.selections.count < 8){
        [self.imageGridView deleteItemsAtIndexPaths:@[indexPath]];
        
    }else if(self.selections.count == 8){
        [self.imageGridView reloadItemsAtIndexPaths:@[indexPath]];
    }
    [self adjustGridView:self.selections.count];
}

-(void)respondsToNextBtn:(NSArray *)selections
{
    [self.selections removeAllObjects];
    [self.selections addObjectsFromArray:selections];
    
    CGFloat gridWidth = (ScreenWidth - 22) / 3;
    ComposePhotoGridViewCellSize = CGSizeMake(gridWidth, gridWidth);
    ((UICollectionViewFlowLayout*)self.imageGridView.collectionViewLayout).itemSize = ComposePhotoGridViewCellSize;
    
    [self adjustGridView:self.selections.count];
    
    //[self textViewChanged:nil];
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
        self.scrollView.scrollEnabled = NO;
//        CGRect frame = self.containtView.frame;
//        frame.size.height -= 100;
//        self.containtView.frame = frame;
//        [self.containtView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(self.view.frame.size.height);
//        }];
    }else{
        self.scrollView.scrollEnabled = YES;
        self.imageGridView.hidden = NO;
        [self.imageGridView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(((count + 2) / 3) * ComposePhotoGridViewCellSize.height + 4);
        }];
        [self.imageGridView reloadData];
//        CGRect frame = self.containtView.frame;
//        frame.size.height += 100;
//        self.containtView.frame = frame;
//        [self.containtView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(self.imageGridView.frame.origin.y + self.imageGridView.frame.size.height + 20);
//        }];
    }
}

-(void)showComposeVC
{
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    PickPhotosCollectionVC *picPhotosCVC = [sb instantiateViewControllerWithIdentifier:@"Pick Photos CVC"];
//    [picPhotosCVC.selections addObjectsFromArray: self.selections];
//    picPhotosCVC.delegate = self;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picPhotosCVC];
    [self performSegueWithIdentifier:@"Show PickPhotoCVC" sender:self];
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
        FullScreenImageView *fullSIV = [[FullScreenImageView alloc] initWithFrame:self.view.frame withType:FullScreenImageViewNoneType];
        [self.view.window addSubview:fullSIV];
        [self.cachingImageManager requestImageForAsset:self.selections[indexPath.item]
                                            targetSize:self.view.frame.size
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                   [fullSIV updateImage:result];
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
                    [pickPhotoCVC.selections addObjectsFromArray:self.selections];
                }
            }
        }
        
    }
    
}


@end
