//
//  CollectionViewCell.h
//  MXDeleteWaveAnimationDemo
//
//  Created by yellow on 2017/8/11.
//  Copyright © 2017年 yellow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UICollectionViewCellDelegate <NSObject>

/**
 长按事件

 @param indexPath indexPath
 */
- (void)cellLongPressed:(NSIndexPath*)indexPath;

/**
 删除事件

 @param indexPath indexPath
 */
- (void)cellDelete:(NSIndexPath*)indexPath;

@end

@interface CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <UICollectionViewCellDelegate>delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

/**
 显示删除动画
 */
@property (assign, nonatomic) BOOL showDeleteAnimation;

/**
 显示长按选中动画
 */
@property (assign, nonatomic) BOOL showLongPressAnimation;

@end
