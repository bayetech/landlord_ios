//
//  CYPhotosManager.m
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYPhotosManager.h"
#import "CYPhotosCollection.h"
#import "CYPhotosKit.h"
@implementation CYPhotosManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static CYPhotosManager *_photoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _photoManager = [super allocWithZone:zone];
    });
    return _photoManager;
}
/**
 *  获取图片资源管理者实例
 */
+ (_Nullable instancetype)defaultManager {

    return [[super alloc] init];
}
/**
 *  所有照片的集合
 */
- (NSMutableArray <CYPhotosCollection *>*_Nullable)requestAllPhotosOptions {
    
    PHFetchOptions *allPhotosOptions    = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors    = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *allPhotos            = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    PHAsset *asset                      = [allPhotos firstObject];
    CYPhotosCollection *photoCollection = [CYPhotosCollection new];
    photoCollection.count               = [NSString stringWithFormat:@"%lu",(unsigned long)allPhotos.count];
    photoCollection.thumbnail           = [self getImageWithAsset:asset];
    photoCollection.fetchResult         = allPhotos;
    photoCollection.localizedTitle      = @"相机胶卷";

    return [NSMutableArray arrayWithObject:photoCollection];
}
/**
 *  系统创建的一些相册
 */
- (NSMutableArray <CYPhotosCollection *>*_Nullable)requestSmartAlbums {
    __weak typeof(self)weakSelf         = self;
    PHFetchResult *smartAlbums          = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

    __block NSMutableArray *photoGroups = [NSMutableArray array];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        PHFetchResult *assetsFetchResult    = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        if ([strongSelf needAddPhotoGroup:collection] && assetsFetchResult.count>0) {
            
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
            CYPhotosCollection *photoAsset   = [CYPhotosCollection new];
            photoAsset.count                 = [NSString stringWithFormat:@"%lu",(unsigned long)assetsFetchResult.count];
            photoAsset.thumbnail             = [self getNearByImage:(PHAssetCollection *)collection];
            photoAsset.fetchResult           = assetsFetchResult;
            photoAsset.localizedTitle        = [self getPhotoGroupName:collection];
            [photoGroups addObject:photoAsset];
        }
    }];

    return photoGroups;

}
/**
 *  用户自己创建的相册
 */
- (NSMutableArray <CYPhotosCollection *>*_Nullable)requestTopLevelUserCollections {
    
    PHFetchResult *topLevelUserCollections  = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    __block NSMutableArray *userPhotoGroups = [NSMutableArray array];
    [topLevelUserCollections enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        if (assetsFetchResult.count>0) {
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
            CYPhotosCollection *photoAsset   = [CYPhotosCollection new];
            photoAsset.count                 = [NSString stringWithFormat:@"%lu",(unsigned long)assetsFetchResult.count];
            photoAsset.thumbnail             = [self getNearByImage:(PHAssetCollection *)collection];
            photoAsset.fetchResult           = assetsFetchResult;
            photoAsset.localizedTitle        = [self getPhotoGroupName:collection];
            [userPhotoGroups addObject:photoAsset];
        }
    }];
    return userPhotoGroups;
}
/**
 *  判断是否将一个photoGroup展示出来
 */
- (BOOL)needAddPhotoGroup:(PHAssetCollection *)collection {
    if ([collection.localizedTitle isEqualToString:@"Screenshots"]) {
        return YES;
    }else if ([collection.localizedTitle isEqualToString:@"Selfies"]) {
        return YES;
    }else if ([collection.localizedTitle isEqualToString:@"Recently Added"]) {
        return YES;
    }else if ([collection.localizedTitle isEqualToString:@"Favorites"]) {
        return YES;
    }else if ([collection.localizedTitle isEqualToString:@"Videos"]) {
        return YES;
    }
    return NO;
}
/**
 *  得到每个组的中文名称
 */
- (NSString *)getPhotoGroupName:(PHCollection *)collection {
    if ([collection.localizedTitle isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    }else if ([collection.localizedTitle isEqualToString:@"Selfies"]) {
        return @"自拍";
    }else if ([collection.localizedTitle isEqualToString:@"Recently Added"]) {
        return @"最新添加";
    }else if ([collection.localizedTitle isEqualToString:@"Favorites"]) {
        return @"个人收藏";
    }else if ([collection.localizedTitle isEqualToString:@"Videos"]) {
        return @"视频";
    }
    return collection.localizedTitle;
}
/**
 *  每个相册组最近一张照片的缩略图
 */
- (UIImage *)getNearByImage:(PHAssetCollection *)collection {
    
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    if (assetsFetchResult.count == 0) {
        UIImage *img = [UIImage imageNamed:imageNameInBundle(@"xiangqing_add2") inBundle:bundleWithClass(self) compatibleWithTraitCollection:nil];

        return img;
    }
    PHAsset *asset =[assetsFetchResult firstObject];
    return [self getImageWithAsset:asset];
}
/**
 *  根据已 asset 获取一张图片资源
 */
- (UIImage *)getImageWithAsset:(PHAsset *)asset {
    PHImageManager *imageManager = [PHImageManager defaultManager];
    __block  UIImage *sourceImage = nil;
    [imageManager requestImageForAsset:asset targetSize:CGSizeMake(2000.0f, 2000.0f) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        sourceImage = result;
    }];
    return sourceImage;
}


@end
