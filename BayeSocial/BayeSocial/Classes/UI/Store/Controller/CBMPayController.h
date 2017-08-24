//
//  CBMPayController.h
//  Baye
//
//  Created by 左坤 on 16/7/22.
//  Copyright © 2016年 Bayekeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  CBMPayController;

@protocol CBMPayControllerDelegate <NSObject>

@optional
-(void)goOrderVC:(CBMPayController*)vc;
-(void)cancelPay:(CBMPayController*)vc;
@end
@interface CBMPayController : UIViewController
- (void)loadUrl:(NSString*)outerURL;
- (void)loadURLRequest:(NSURLRequest*)requesturl;
 @property(nonatomic,weak)  id<CBMPayControllerDelegate> delegate;
@end
