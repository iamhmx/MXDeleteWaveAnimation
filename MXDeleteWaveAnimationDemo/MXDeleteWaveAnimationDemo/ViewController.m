//
//  ViewController.m
//  MXDeleteWaveAnimationDemo
//
//  Created by yellow on 2017/8/11.
//  Copyright © 2017年 yellow. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewCellDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
/**
 删除动画标识
 */
@property (assign, nonatomic) BOOL readyForDelete;

/**
 长按手势
 */
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGes;

/**
 长按选中的cell
 */
@property (strong, nonatomic) CollectionViewCell *selectedCell;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *colorArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MXDeleteWaveAnimationDemo";
    self.dataSource = [NSMutableArray new];
    self.colorArray = [NSMutableArray new];
    for (NSInteger i = 0; i < 20; i++) {
        [self.colorArray addObject:[UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1]];
        [self.dataSource addObject:@(1)];
    }
    [self.view addSubview:self.collectionView];
    
    //添加长按手势
    self.longPressGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [self.collectionView addGestureRecognizer:self.longPressGes];
    
    [self addObserver:self forKeyPath:@"readyForDelete" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)longPressAction:(UILongPressGestureRecognizer*)ges {
    switch (ges.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"began");
            NSIndexPath *selectIndexPath = [self.collectionView indexPathForItemAtPoint:[ges locationInView:self.collectionView]];
            
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
            //如果没有处于删除状态，打开删除
            if (!self.readyForDelete) {
                self.readyForDelete = YES;
            }
            
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            NSLog(@"changed");
            [self.collectionView updateInteractiveMovementTargetPosition:[ges locationInView:self.collectionView]];
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            NSLog(@"end");
            [self.collectionView endInteractiveMovement];
            self.selectedCell.showLongPressAnimation = NO;
            break;
        }
            
        default: {
            NSLog(@"cancel");
            [self.collectionView cancelInteractiveMovement];
            self.selectedCell.showLongPressAnimation = NO;
            break;
        }
    }
}

#pragma mark Cell代理
- (void)cellLongPressed:(NSIndexPath *)indexPath {
    self.readyForDelete = YES;
}

- (void)cellDelete:(NSIndexPath *)indexPath {
    [self.collectionView performBatchUpdates:^{
        [self.colorArray removeObjectAtIndex:indexPath.row];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
        if (self.dataSource.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
}

- (void)endEdit {
    self.readyForDelete = NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //传入indexPath，代理返回，定位cell
    cell.indexPath = indexPath;
    cell.backgroundColor = self.colorArray[indexPath.row];
    cell.delegate = self;
    cell.showDeleteAnimation = self.readyForDelete;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //id obj = self.dataSource[sourceIndexPath.row];
    //[self.dataSource removeObjectAtIndex:sourceIndexPath.row];
    //[self.dataSource insertObject:obj atIndex:destinationIndexPath.item];
    NSLog(@"source: %ld",sourceIndexPath.row);
    NSLog(@"destin: %ld",destinationIndexPath.row);
    /*[self.dataSource exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self.colorArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self.collectionView reloadData];*/
    
    id obj = self.dataSource[sourceIndexPath.row];
    id color = self.colorArray[sourceIndexPath.row];
    [self.dataSource removeObjectAtIndex:sourceIndexPath.row];
    [self.dataSource insertObject:obj atIndex:destinationIndexPath.row];
    
    [self.colorArray removeObjectAtIndex:sourceIndexPath.row];
    [self.colorArray insertObject:color atIndex:destinationIndexPath.row];
    
    //移动完成后要修改index有变化的cell，否则删除会错乱
    for (NSInteger i = MIN(destinationIndexPath.row, sourceIndexPath.row); i < MAX(destinationIndexPath.row, sourceIndexPath.row) + 1; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CollectionViewCell *cell = (CollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.indexPath = indexPath;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"readyForDelete"]) {
        [self.collectionView reloadData];
        if (self.readyForDelete) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"结束编辑" style:UIBarButtonItemStylePlain target:self action:@selector(endEdit)];
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(80, 80);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"readyForDelete"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
