//
//  CYCollectionViewCell.m
//  CYPhotoKit
//
//  Created by dongzb on 16/3/20.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYCollectionViewCell.h"

@implementation CYCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];

}


- (IBAction)delegateButtonClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(bkCollectionViewCellDidSelectDelegateButton:)]) {
        [self.delegate bkCollectionViewCellDidSelectDelegateButton:self];
    }
}


@end
