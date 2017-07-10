//
//  CYAuthorizedFailureViewController.h
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/6.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  获取相册授权失败的控制器
 */
@interface CYAuthorizedFailureViewController : UIViewController

- (IBAction)settingButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;

@end
