//
//  PhotoCollectionViewCell.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/25.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@interface PhotoCollectionViewCell ()
@property (strong, nonatomic) IBOutlet UIImageView *cameraImage;
@property (strong, nonatomic) IBOutlet UIButton *smallButton;
@property (strong, nonatomic) IBOutlet UIImageView *smallImageView;
@property (strong, nonatomic) IBOutlet UIImageView *bigImageView;

@end

@implementation PhotoCollectionViewCell



-(UIImageView *)cameraImage
{
    if(!_cameraImage){
        _cameraImage = [[UIImageView alloc] init];
        CGFloat scale = ([UIScreen mainScreen].bounds.size.width - 4) / 3;
        CGFloat space = scale * (1 - 0.43) / 2;
        CGRect rect = CGRectMake(space, space, scale * 0.43, scale * 0.43);
        self.cameraImage.frame = rect;
        [self.cameraImage setImage:[UIImage imageNamed:@"compose_photo_photograph"]];
        [self addSubview:self.cameraImage];
    }
    return _cameraImage;
}

-(void)setImage:(UIImage*)image withIndex:(NSUInteger)cellIndex
{
    if(cellIndex == 0){
        self.cameraImage.hidden = NO;
        self.smallButton.hidden =  YES;
        self.smallImageView.hidden = YES;
        self.bigImageView.hidden = YES;
        //[self.bigImageView setImage:image];
        //[self.cameraImage setFrame:self.bounds];
        //NSLog(@"%@", NSStringFromCGRect(self.cameraImage.frame));
    }else{
        self.smallButton.hidden = NO;
        self.smallImageView.hidden = NO;
        self.bigImageView.hidden = NO;
        self.cameraImage.hidden = YES;
        self.smallButton.tag = cellIndex;
        [self.bigImageView setImage:image];
        if(self.smallButton.hidden == NO && self.selected){
            [self.smallImageView setImage:[UIImage imageNamed:@"compose_guide_check_box_right"]];
        }else{
            [self.smallImageView setImage:[UIImage imageNamed:@"compose_guide_check_box_default"]];
        }
        [self bringSubviewToFront:self.smallButton];
    }
}

-(void)updateCheckImage
{
    if(self.smallButton.hidden == NO && self.selected){
        [self.smallImageView setImage:[UIImage imageNamed:@"compose_guide_check_box_right"]];
    }else{
        [self.smallImageView setImage:[UIImage imageNamed:@"compose_guide_check_box_default"]];
    }
}

//- (IBAction)bigButtonClicked:(id)sender {
//    if([sender isKindOfClass:[UIButton class]]){
//        UIButton *btn = (UIButton*)sender;
//        if (btn.tag == 100001) {
//            
//        }else{
//            
//        }
//    }
//}

- (IBAction)smallButtonClicked:(id)sender {
    [self respondToButtonClicked:sender];
}

-(void)respondToButtonClicked:(id)sender{
    if([self.delegate respondsToSelector:@selector(collectionCellViewButtonClicked:)]){
        [self.delegate collectionCellViewButtonClicked:sender];
    }
}

@end
