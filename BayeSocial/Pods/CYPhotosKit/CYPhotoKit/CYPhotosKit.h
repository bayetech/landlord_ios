//
//  CYPhotosKit.h
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#ifndef CYPhotosKit_h
#define CYPhotosKit_h

#import <UIKit/UIKit.h>
#import "CYPhotoNavigationController.h"
#import "CYPhotosManager.h"
#import "CYPhotosAsset.h"
#import "CYPhotosCollection.h"

#define appWindow [[[UIApplication sharedApplication]delegate]window]

#define dispatch_main_safe(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}

#define dispatch_global_safe(block)   if (![NSThread isMainThread]) {\
    block();\
}   else {\
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);\
}

// 获取当前文件所在的 bundle
#define bundleWithClass(cls) [NSBundle bundleForClass:[cls class]]

#define imageNameInBundle(_named) [NSString stringWithFormat:@"ImageBundle.bundle/%@",_named]


#ifdef DEBUG
// DEBUG模式下进行调试打印

// 输出结果标记出所在类方法与行数
#define DLog(fmt, ...)   NSLog((@"\n%s[Line: %d]™ ->" fmt), strrchr(__FUNCTION__,'['), __LINE__, ##__VA_ARGS__)

#else

#define DLog(...)   {}

#endif

/**
 *  最大选取照片的数量
 */
static NSInteger const maxSelectPhotoCount  = 9;


#endif /* CYPhotosKit_h */
