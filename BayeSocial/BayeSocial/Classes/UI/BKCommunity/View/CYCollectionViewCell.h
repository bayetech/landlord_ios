//
//  CYCollectionViewCell.h
//  CYPhotoKit
//
//  Created by dongzb on 16/3/20.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CYCollectionViewCellDelegate;

@interface CYCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic,nullable) IBOutlet NSLayoutConstraint *imageViewRight;
@property (weak, nonatomic,nullable) IBOutlet NSLayoutConstraint *delegateButtonHeight;
@property (weak, nonatomic,nullable) IBOutlet NSLayoutConstraint *delegateButtonWidth;

@property (weak, nonatomic,nullable) IBOutlet NSLayoutConstraint *imageViewTop;
@property (weak, nonatomic,nullable) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic,nullable) IBOutlet UIImageView *imageView;

/** delegate  */
@property (nonatomic,weak,nullable) id<CYCollectionViewCellDelegate>delegate;

@end

@protocol CYCollectionViewCellDelegate <NSObject>

@optional
/**
 *  点击了删除按钮
 */
- (void)bkCollectionViewCellDidSelectDelegateButton:(CYCollectionViewCell *_Nullable)cell;


@end
