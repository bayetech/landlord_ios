//
//  CYPhotoGroupController.m
//  CYPhotoKit
//
//  Created by dongzb on 16/3/20.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYPhotoGroupController.h"
#import "CYPhotosKit.h"
#import "CYAuthorizedFailureViewController.h"
#import "CYPhotoLibrayGroupCell.h"
#import "CYPhotoListViewController.h"

static NSString *const photoLibrayGroupCell   = @"CYPhotoLibrayGroupCell";
static NSString *const smartAlbumsIdentifier = @"smartAlbumsIdentifier";


@interface CYPhotoGroupController () <PHPhotoLibraryChangeObserver,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray     *sectionFetchResults;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CYPhotoGroupController

- (void)viewDidLoad{
    [super viewDidLoad];

    [self setup];
    
    UIWindow *window  = appWindow;
    UIActivityIndicatorView *_activityView  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame                     = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    _activityView.hidesWhenStopped          = YES;
    _activityView.tag                       = 1000;
    _activityView.center                    = window.center;
    [_activityView startAnimating];
    [window addSubview:_activityView];
    
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIActivityIndicatorView *_activityView = [[[UIApplication sharedApplication].delegate window] viewWithTag:1000];
    if (_activityView != nil) {
        [_activityView removeFromSuperview];
    }
}

- (void)setup {
    
    self.title                              = @"照片";

    __weak typeof(self)weakSelf             = self;
    // 判断是否能够访问相册功能
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (status == PHAuthorizationStatusDenied) {
            DLog(@"用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关");
            [strongSelf performSelectorOnMainThread:@selector(showAuthorizedFailureViewController) withObject:nil waitUntilDone:NO];
        }else if (status == PHAuthorizationStatusRestricted){
            DLog(@"家长控制,不允许访问");
            [strongSelf performSelectorOnMainThread:@selector(showAuthorizedFailureViewController) withObject:nil waitUntilDone:NO];
        }else if (status == PHAuthorizationStatusNotDetermined){
            DLog(@"用户还没有做出选择");
        }else if (status == PHAuthorizationStatusAuthorized){
            DLog(@"用户允许当前应用访问相册");
            [strongSelf performSelectorOnMainThread:@selector(photosAuthorizedSuccess) withObject:nil waitUntilDone:NO];
        }
        
    }];
    
    self.view.backgroundColor              = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];

}

- (void)showAuthorizedFailureViewController {

    UIActivityIndicatorView *_activityView = [[[UIApplication sharedApplication].delegate window] viewWithTag:1000];
    if (_activityView != nil) {
        [_activityView removeFromSuperview];
    }
    
    CYAuthorizedFailureViewController *failureViewController = [[CYAuthorizedFailureViewController alloc] initWithNibName:@"CYAuthorizedFailureViewController" bundle:bundleWithClass(CYAuthorizedFailureViewController)];
    
    [self.navigationController pushViewController:failureViewController animated:NO];

}

- (void)photosAuthorizedSuccess {
    
    [self.view addSubview:self.tableView];
    
    [self addObserVer]; // 添加监听
    
    __weak typeof(self)weakSelf             = self;
    
    NSBlockOperation *syncBlock = [NSBlockOperation blockOperationWithBlock:^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        CYPhotosManager *photosManager      = [CYPhotosManager defaultManager];
        strongSelf.sectionFetchResults      = @[[photosManager requestAllPhotosOptions], [photosManager requestSmartAlbums], [photosManager requestTopLevelUserCollections]];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 如果所有照片有照片 就进所有照片的详情页面
            NSArray *array = strongSelf.sectionFetchResults.firstObject;
            [strongSelf.tableView reloadData];
            if ([array count] > 0) {
                CYPhotosCollection *photoCollection = [array firstObject];
                [strongSelf openPhotosListViewController:photoCollection animated:NO];
            }
        }];
     
    }];
    
    [syncBlock start];
    

}

/**
 *  添加监听方法
 */
- (void)addObserVer {
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

}

#pragma mark - 按钮点击事件

- (void)dismiss {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photosViewControllDismiss" object:nil];
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView                 = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate        = self;
        _tableView.dataSource      = self;
        [_tableView registerNib:[UINib nibWithNibName:@"CYPhotoLibrayGroupCell" bundle:bundleWithClass(CYPhotoLibrayGroupCell)] forCellReuseIdentifier:photoLibrayGroupCell];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}


#pragma mark - 相册资源发生改变

- (void)photoLibraryDidChange:(PHChange *)changeInstance {



}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionFetchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        
        return 1;
    } else {
        
        PHFetchResult *result = self.sectionFetchResults[section];
        return result.count;
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CYPhotoLibrayGroupCell *cell         = [tableView dequeueReusableCellWithIdentifier:photoLibrayGroupCell];

    NSArray *fetchResult                 = self.sectionFetchResults[indexPath.section];
    CYPhotosCollection *photosCollection = fetchResult[indexPath.row];

    cell.photoImageView.image            = photosCollection.thumbnail;
    
    cell.titleLabel.text                 = [NSString stringWithFormat:@"%@ (%@)",photosCollection.localizedTitle,photosCollection.count];


    return cell;

}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *fetchResult                 = self.sectionFetchResults[indexPath.section];
    CYPhotosCollection *photosCollection = fetchResult[indexPath.row];

    [self openPhotosListViewController:photosCollection animated:YES];

}

/**
 *  打开单个相册所有照片详情的页面
 */
- (void)openPhotosListViewController:(CYPhotosCollection*)photosCollection animated:(BOOL)animated {

    NSBundle *bundle = [NSBundle bundleForClass:[CYPhotoListViewController class]];
    
    CYPhotoListViewController *photoDetailVC = [[CYPhotoListViewController alloc] initWithNibName:@"CYPhotoListViewController" bundle:bundle];
    photoDetailVC.fetchResult                = photosCollection.fetchResult;
    photoDetailVC.title                      = photosCollection.localizedTitle;
    [self.navigationController pushViewController:photoDetailVC animated:animated];

}


- (void)dealloc {
    
    DLog(@"dealloc - %@",self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    
    
}

@end
