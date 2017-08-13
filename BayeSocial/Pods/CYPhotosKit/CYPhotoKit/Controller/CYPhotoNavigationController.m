//
//  CYPhotoNavigationController.m
//  CYPhotoKit
//
//  Created by dongzb on 16/3/20.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//


#import "CYPhotoNavigationController.h"
#import "CYPhotoGroupController.h"
#import "CYPhotosKit.h"

@interface CYPhotoNavigationController ()
{
    
    id <CYPhotoNavigationControllerDelegate,UINavigationControllerDelegate> _cyDelegate;
    
}
@property (nonatomic,strong) CYPhotoGroupController *cyPhotoGroupViewController;

@end

@implementation CYPhotoNavigationController

@dynamic delegate;

- (void)setDelegate:(id<CYPhotoNavigationControllerDelegate,UINavigationControllerDelegate>)delegate {
    _cyDelegate = delegate;
}

- (id<CYPhotoNavigationControllerDelegate,UINavigationControllerDelegate>)delegate {
    return _cyDelegate;
}

+ (_Nonnull instancetype)showPhotosViewController
{
    CYPhotoGroupController *cyPhotoGroupViewController = [[CYPhotoGroupController alloc] init];
    
    CYPhotoNavigationController *navigationController = [[CYPhotoNavigationController alloc] initWithRootViewController:cyPhotoGroupViewController];
    navigationController.maxPickerImageCount          = maxSelectPhotoCount;
    return navigationController;
}
#pragma mark - 监听通知
- (void)dismiss {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
/**
 *  选择完成后的通知方法 在这里处理回调
 */
- (void)didFinished:(NSNotification *)noti {
    
    NSArray <CYPhotosAsset *>*array = noti.object;
    
    if ([self.delegate respondsToSelector:@selector(cyPhotoNavigationController:didFinishedSelectPhotos:)]) {
        [self.delegate cyPhotoNavigationController:self didFinishedSelectPhotos:array];
    }
    if (self.completionBlock) {
        self.completionBlock(array);
    }
    
    [self dismiss];
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self isEmpty];
        [self addObserver];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    if (self = [super initWithRootViewController:rootViewController]) {
        
        [self isEmpty];
        [self addObserver];
        
    }
    return self;
}

- (void)addObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"photosViewControllDismiss" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinished:) name:@"photosViewControllerDidFinished" object:nil];
    
}
/**
 *  判断rootViewController 是否为 CYPhotoGroupController ,实例化方法 showPhotosViewController 不能使用其他 controlller 作为 CYPhotoNavigationController 的 rootViewController
 */
- (void)isEmpty {
    
    UIViewController *rootViewController = [self.viewControllers firstObject];
    BOOL result = (!rootViewController||![rootViewController isKindOfClass:[CYPhotoGroupController class]]);
    NSAssert(!result, @"\n\n请指定 CYPhotoGroupController类型的 rootViewController 或者调用 showPhotosViewController 方法\n");
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
}

- (CYPhotoGroupController *)cyPhotoGroupViewController{
    if (!_cyPhotoGroupViewController) {
        _cyPhotoGroupViewController = [[CYPhotoGroupController alloc] init];
    }
    return _cyPhotoGroupViewController;
}

- (void)dealloc {
    
    //    CYLog(@"--dealloc--\n");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


@end
