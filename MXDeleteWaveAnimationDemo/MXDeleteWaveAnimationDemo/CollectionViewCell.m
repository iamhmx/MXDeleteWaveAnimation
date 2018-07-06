//
//  CollectionViewCell.m
//  MXDeleteWaveAnimationDemo
//
//  Created by yellow on 2017/8/11.
//  Copyright © 2017年 yellow. All rights reserved.
//

#import "CollectionViewCell.h"

#define Angle(a) (M_PI_2/90 * a)

@interface CollectionViewCell ()
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger radio;
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@end

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    /*//添加长按手势
    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPressGes];*/
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
}

- (void)setShowDeleteAnimation:(BOOL)showDeleteAnimation {
    _showDeleteAnimation = showDeleteAnimation;
    if (showDeleteAnimation) {
        self.deleteButton.hidden = NO;
        [self startDeleteAnimation];
    } else {
        self.deleteButton.hidden = YES;
        [self closeDeleteAnimation];
    }
}

- (void)setShowLongPressAnimation:(BOOL)showLongPressAnimation {
    _showLongPressAnimation = showLongPressAnimation;
    [self longPressAnimationDisplay:showLongPressAnimation];
}

- (void)startDeleteAnimation {
    self.layer.transform = CATransform3DIdentity;
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)closeDeleteAnimation {
    self.layer.transform = CATransform3DIdentity;
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)longPressAnimationDisplay:(BOOL)display {
    [UIView animateWithDuration:0.2 animations:^{
        if (display) {
            self.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1);
        } else {
            self.layer.transform = CATransform3DIdentity;
        }
    } completion:^(BOOL finished) {
        if (display) {
            self.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1);
        } else {
            self.layer.transform = CATransform3DIdentity;
        }
    }];
}

- (void)longPressAction:(id)sender {
    if (self.showDeleteAnimation) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(cellLongPressed:)]) {
        [self.delegate cellLongPressed:self.indexPath];
    }
}

- (IBAction)deleteAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cellDelete:)]) {
        [self.delegate cellDelete:self.indexPath];
    }
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [UIView animateKeyframesWithDuration:0.4 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear | UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2 animations:^{
                    self.layer.transform = CATransform3DRotate(CATransform3DMakeTranslation(self.x, self.y, 0), Angle(self.radio), 0, 0, 1);
                }];
                [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.2 animations:^{
                    self.layer.transform = CATransform3DRotate(CATransform3DMakeTranslation(-self.x, -self.y, 0), Angle(self.radio), 0, 0, -1);
                }];
            } completion:^(BOOL finished) {
                
            }];
        }];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

#pragma mark - 随机摇摆
//角度
- (NSInteger)radio {
    return arc4random() % 2;
}

//x，1 ~ 2.0 step 0.1
- (CGFloat)x {
    return (arc4random() % 20) / 10.0;
}

//y，1 ~ 2.0 step 0.1
- (CGFloat)y {
    return (arc4random() % 20) / 10.0;
}

@end
