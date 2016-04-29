//
//  ComposePhotoGridView.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/29.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "ComposePhotoGridView.h"

@interface ComposePhotoGridView ()



@end



@implementation ComposePhotoGridView





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@interface ComposePhotoGridViewCell ()


@end

@implementation ComposePhotoGridViewCell
- (IBAction)cellDeleteButton:(id)sender {
    if([self.delegate respondsToSelector:@selector(composePhotoCellButtonClicked:)]){
        [self.delegate composePhotoCellButtonClicked:self];
    }
}



@end
