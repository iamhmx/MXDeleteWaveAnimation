//
//  ViewController.m
//  MXDeleteWaveAnimationDemo
//
//  Created by msxf on 2017/8/11.
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
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *colorArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"长按删除";
    self.dataSource = [NSMutableArray new];
    self.colorArray = [NSMutableArray new];
    for (NSInteger i = 0; i < 20; i++) {
        [self.colorArray addObject:[UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1]];
        [self.dataSource addObject:@(1)];
    }
    [self.view addSubview:self.collectionView];
    [self addObserver:self forKeyPath:@"readyForDelete" options:NSKeyValueObservingOptionNew context:nil];
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
