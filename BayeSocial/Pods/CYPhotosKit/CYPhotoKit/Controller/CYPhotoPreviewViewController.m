//
//  CYPhotoPreviewViewController.m
//  CYPhotoKit
//
//  Created by dzb on 16/9/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYPhotoPreviewViewController.h"
#import "CYPhotoPreviewCollectionViewCell.h"
#import "CYPhotosAsset.h"
#import "CYPhotosKit.h"

@interface CYPhotoPreviewViewController () <UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UIButton      *checkBoxButton;
@property (nonatomic,assign) NSInteger     pageIndex;
@property (nonatomic,strong) NSMutableArray <CYPhotosAsset *> *selectImages;

@end

@implementation CYPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor              = [UIColor whiteColor];
    self.pageIndex                         = 0;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CYPhotoPreviewCollectionViewCell" bundle:bundleWithClass(CYPhotoPreviewCollectionViewCell)] forCellWithReuseIdentifier:@"CYPhotoPreviewCollectionViewCell"];
    self.collectionView.delegate           = self;
    self.collectionView.dataSource         = self;

    UIButton *checkBoxBtn                  = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkBoxBtn setImage:[UIImage imageNamed:imageNameInBundle(@"AssetsPickerChecked") inBundle:bundleWithClass(self) compatibleWithTraitCollection:nil] forState:UIControlStateSelected];

    [checkBoxBtn addTarget:self action:@selector(checkBoxClick:) forControlEvents:UIControlEventTouchUpInside];
    checkBoxBtn.frame                      = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
    self.checkBoxButton                    = checkBoxBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:checkBoxBtn];

    [self setCheckBoxButtonState:0];

    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle: @"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
}

- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

/**
 *  设置 checkbox 状态
 */
- (void)setCheckBoxButtonState:(NSInteger)index {
    
    CYPhotosAsset *photoAsset    = self.soureImages[index];
    self.checkBoxButton.selected = photoAsset.isSelectImage;
    self.pageIndex               = index;
    
}

- (void)checkBoxClick:(UIButton *)checkBtn {
    
    CYPhotosAsset *photoAsset    = self.soureImages[self.pageIndex];
    photoAsset.selectImage       = !photoAsset.selectImage;
    self.checkBoxButton.selected = photoAsset.isSelectImage;

    if (photoAsset.selectImage) {
        [self.selectImages addObject:photoAsset];
    } else {
        [self.selectImages removeObject:photoAsset];
    }
    
}

- (void)setSoureImages:(NSMutableArray<CYPhotosAsset *> *)soureImages {
    _soureImages    = soureImages;
    
    [_soureImages enumerateObjectsUsingBlock:^(CYPhotosAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selectImage = YES;
        [self.selectImages addObject:obj];
        
    }];
}

- (NSMutableArray<CYPhotosAsset *> *)selectImages {
    if (!_selectImages) {
        _selectImages = [NSMutableArray array];
    }
    return _selectImages;
}

//- (void)back {
//    
//    [self.navigationController popViewControllerAnimated:YES];
//    
//}

#pragma mark -  UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section  {
    return self.soureImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CYPhotoPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CYPhotoPreviewCollectionViewCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor       = [UIColor whiteColor];
    CYPhotosAsset *assetModel              = self.soureImages[indexPath.row];
    cell.cyAsset                           = assetModel;

    return  cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger pageIndex = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    [self setCheckBoxButtonState:pageIndex];
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width   = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat height  = self.view.frame.size.height - 84.0f - 64.0f;
    
    return CGSizeMake(width, height);
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(20.0f, 0.0f, 20.0f, 0.0f);
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0.0f;
    
}



@end
