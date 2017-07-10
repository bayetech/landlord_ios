
//
//  CYPhotoListViewController.m
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//
#import "CYPhotosAsset.h"
#import <Photos/Photos.h>
#import "CYPhotoListViewController.h"
#import "CYPhotosCollectionViewCell.h"
#import "CYPhotosKit.h"
#import "CYPhotoPreviewViewController.h"

static CGFloat const itemMarigin = 5.0f;

@interface CYPhotoListViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) PHCachingImageManager *imageManager;
@property (nonatomic,assign) CGSize                itemSize;
@property (nonatomic,strong) NSMutableDictionary   *cacheSelectItems;
@property (nonatomic,strong) NSMutableDictionary   *selectAssetDictionary;
@property (nonatomic,strong) UIView                *bottomView;
@property (nonatomic,assign) BOOL                  needScrollToBottom;
@property (nonatomic,assign) NSInteger  maxCount;

@end

@implementation CYPhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
}

- (void)setup {
    
    CGFloat screenW                          = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemW                            = (screenW - 3*itemMarigin)/4;
    CGFloat itemH                            = itemW;
    self.itemSize                            = CGSizeMake(itemW, itemH);

    [self.collectionView registerNib:[UINib nibWithNibName:@"CYPhotosCollectionViewCell" bundle:bundleWithClass(CYPhotosCollectionViewCell)] forCellWithReuseIdentifier:@"CYPhotosCollectionViewCell"];
    self.collectionView.alwaysBounceVertical = YES;

    self.navigationItem.rightBarButtonItem   = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];

    self.countLabel.layer.cornerRadius       = 10.0f;
    self.countLabel.layer.masksToBounds      = YES;
    self.needScrollToBottom                  = YES;
    self.collectionView.dataSource           = self;
    self.collectionView.delegate             = self;

    // 设置最大选取照片的数量
    CYPhotoNavigationController *nav         = (CYPhotoNavigationController *)self.navigationController;
    self.maxCount                            = nav.maxPickerImageCount;
    self.maxImageLabel.text                  = [NSString stringWithFormat:@"最多可选取%@张相片",@(self.maxCount)];

    [self reloadBottomViewStatus];
    
}

#pragma mark - 按钮点击事件

- (void)dismiss {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photosViewControllDismiss" object:nil];
    
}
/**
 *  查看所选照片的按钮
 */
- (IBAction)previewButtonClick:(id)sender {
    
    CYPhotoPreviewViewController *previewVC = [[CYPhotoPreviewViewController alloc] initWithNibName:@"CYPhotoPreviewViewController" bundle:bundleWithClass(CYPhotoPreviewViewController)];
    previewVC.soureImages                   = [self getSelectImagesArray];
    [self.navigationController pushViewController:previewVC animated:YES];

}
/**
 *  完成按钮选取图片结束
 */
- (IBAction)finishedButtonClick:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photosViewControllerDidFinished" object:[self getSelectImagesArray]];
}

/**
 *  获取用户选中的图片数组
 */
- (NSMutableArray *)getSelectImagesArray {
    
    __block   NSMutableArray *array = [NSMutableArray array];
    [self.selectAssetDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, CYPhotosAsset *photosAsset, BOOL * _Nonnull stop) {
        [array addObject:photosAsset];
    }];
    return  array;
}

- (NSMutableDictionary *)cacheSelectItems {
    if (!_cacheSelectItems) {
        _cacheSelectItems = [NSMutableDictionary dictionary];
    }
    return _cacheSelectItems;
}

- (NSMutableDictionary *)selectAssetDictionary {
    if (!_selectAssetDictionary) {
        _selectAssetDictionary = [NSMutableDictionary dictionary];
    }
    return _selectAssetDictionary;
}

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView                 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-44.0f, self.view.frame.size.width, 44.0f)];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIActivityIndicatorView *_activityView = [[[UIApplication sharedApplication].delegate window] viewWithTag:1000];
    if (_activityView != nil) {
        [_activityView removeFromSuperview];
    }

}

- (void)setFetchResult:(PHFetchResult<PHAsset *> *)fetchResult {
    _fetchResult    = fetchResult;
    
    __weak typeof(self)weakSelf = self;
    
    void (^block) () = ^ {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        for (int i=0; i<_fetchResult.count; i++) {
            NSString *key = [NSString stringWithFormat:@"%d",i];
            [strongSelf.cacheSelectItems setObject:@"0" forKey:key];
        }
    };
    
    dispatch_global_safe(block);
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.needScrollToBottom) return;
    // 照片超过一个屏幕就滚动到最底部
    if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
        [self collectionViewScrollToBottom];
    }
}
/**
 *  滚动到最底部
 */
- (void)collectionViewScrollToBottom {
    
    CGPoint off             = self.collectionView.contentOffset;
    off.y                   = self.collectionView.contentSize.height - self.collectionView.bounds.size.height + self.collectionView.contentInset.bottom;
    [self.collectionView setContentOffset:off animated:NO];
    self.needScrollToBottom = NO;
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CYPhotosCollectionViewCell *photosCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CYPhotosCollectionViewCell" forIndexPath:indexPath];
    
    [self setupCollectionViewCell:photosCell atIndexPath:indexPath];
    
    return photosCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(itemMarigin, 0.0f, itemMarigin, 0.0f);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return itemMarigin;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return itemMarigin;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *asset             = [self.fetchResult objectAtIndex:indexPath.item];
    CYPhotosAsset *photosAsset = [CYPhotosAsset new];
    photosAsset.asset          = asset;
    
    NSString *key              = [NSString stringWithFormat:@"%@",@(indexPath.item)];
    BOOL isSelect              = ![self.cacheSelectItems[key] boolValue];
    NSString *flag             = nil;
    if (isSelect) {
        if (self.selectAssetDictionary.count<= self.maxCount - 1) {
            self.selectAssetDictionary[key] = photosAsset;
            flag                            = @"1";
            [self reloadBottomViewStatus];
        } else {
            flag = @"0";
            [self showAlertView];
        }
    } else {
        flag = @"0";
        [self.selectAssetDictionary removeObjectForKey:key];
        [self reloadBottomViewStatus];
    }
    
    self.cacheSelectItems[key]             = flag;
    
    CYPhotosCollectionViewCell *photosCell = (CYPhotosCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    [self setupCollectionViewCell:photosCell atIndexPath:indexPath];
    
}

- (void)setupCollectionViewCell:(CYPhotosCollectionViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *asset    = [self.fetchResult objectAtIndex:indexPath.item];
    NSString *key     = [NSString stringWithFormat:@"%@",@(indexPath.item)];
    
    BOOL select       = [self.cacheSelectItems[key] boolValue];
    cell.selectItem   = select;
    cell.imageManager = self.imageManager;
    cell.photosAsset  = asset;
    
}

- (void)showAlertView {
    
    NSString *msg = [NSString stringWithFormat:@"选取的照片不能超过%ld张",(long)self.maxCount];
    
    UIAlertController *alertViewControler = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertViewControler addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alertViewControler animated:YES completion:nil];
    
}
/**
 *  刷新底部工具条状态
 */
- (void)reloadBottomViewStatus {
    
    NSInteger selectItemCount   = self.selectAssetDictionary.count;
    self.previewButton.enabled  = selectItemCount>0;
    self.finishedButton.enabled = self.previewButton.enabled;
    
    self.finishedButton.alpha   = selectItemCount == 0 ? 0.5f : 1.0f;
    self.previewButton.alpha    = self.finishedButton.alpha;
    
    self.countLabel.hidden      = (selectItemCount == 0);
    
    if (!self.countLabel.hidden ) {
        self.countLabel.text    = [NSString stringWithFormat:@"%ld",(long)selectItemCount];
        [UIView animateWithDuration:0.25 animations:^{
            self.countLabel.transform = CGAffineTransformScale(self.countLabel.transform, 0.8f, 0.8f);
        }completion:^(BOOL finished) {
            self.countLabel.transform = CGAffineTransformIdentity;
        }];
    }
    
    
}

- (void)dealloc {
    
    //    CYLog(@"--dealloc--\n");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
