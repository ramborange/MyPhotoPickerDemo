//
//  MyImagePickerViewController.m
//  MyPhotoPickerDemo
//
//  Created by ramborange on 16/6/15.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import "MyImagePickerViewController.h"
#import "MyCollectionViewCell.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "MyPhotoBrowserController.h"

#define kRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface MyImagePickerViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    BOOL isMutiSelect;
    BOOL isClearMuti;
}
@property (nonatomic, strong) UICollectionView *collectionview;

@property (nonatomic, strong) NSMutableArray *selectStatusArray;

@end

@implementation MyImagePickerViewController
- (void)initSelectStatusArray {
    _selectStatusArray = [NSMutableArray arrayWithCapacity:0];
    [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _selectStatusArray[idx] = @(0);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"全选" forState:UIControlStateNormal];
    [btn setTitle:@"取消全选" forState:UIControlStateSelected];
    [btn setTitleColor:kRGB(0, 101, 255) forState:UIControlStateNormal];
    btn.tag = 9;
    [btn addTarget:self action:@selector(selectAllPhotos:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(10, 20, 74, 44);
    [self.view addSubview:btn];
    
    
    [self initSelectStatusArray];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionview = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64-44) collectionViewLayout:layout];
    _collectionview.delegate = self;
    _collectionview.dataSource = self;
    _collectionview.userInteractionEnabled = YES;
    _collectionview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionview];
    [_collectionview registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"collectionviewcellid"];
    
    UITabBar *bottomView = [[UITabBar alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-44,self.view.bounds.size.width,44)];
    bottomView.barTintColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishBtn setTitle:@"取消" forState:UIControlStateNormal];
    [finishBtn setTitle:@"完成" forState:UIControlStateSelected];
    [finishBtn setTitleColor:kRGB(0, 101, 255) forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    finishBtn.tag = 11;
    finishBtn.frame = CGRectMake(self.view.bounds.size.width-60,0,44,44);
    [bottomView addSubview:finishBtn];
    
    UIButton *previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [previewBtn setTitleColor:kRGB(0, 101, 255) forState:UIControlStateNormal];
    [previewBtn addTarget:self action:@selector(previewBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    previewBtn.tag = 12;
    previewBtn.frame = CGRectMake(15,0,44,44);
    [bottomView addSubview:previewBtn];
    previewBtn.hidden = YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"已选择0张";
    label.tag = 13;
    label.textColor = kRGB(0, 101, 255);
    [bottomView addSubview:label];
    
}

#pragma mark - 预览所选的照片
- (void)previewBtnClicked {
    NSMutableArray *retArray  = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *idxArray = [NSMutableArray arrayWithCapacity:0];
    [_selectStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx<_selectStatusArray.count) {
            if ([obj integerValue]) {
                [retArray addObject:_dataArray[idx]];
                [idxArray addObject:@(idx)];
            }
        }
    }];
    MyPhotoBrowserController *photoBrowser = [[MyPhotoBrowserController alloc] init];
   
    __weak __typeof(self) weakSelf = self;
    //预览视图返回
    photoBrowser.previewSelectedStatusBlock = ^(NSMutableArray *selectedStatusArray){
        //更新状态数据
        [selectedStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger currentIdx = [idxArray[idx] integerValue];
            _selectStatusArray[currentIdx] = obj;
        }];
        
        NSMutableArray *indexPathArray = [NSMutableArray arrayWithCapacity:0];
        [idxArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [indexPathArray addObject:[NSIndexPath indexPathForRow:[obj integerValue] inSection:0]];
        }];
        //刷新列表中指定图片
        [_collectionview reloadItemsAtIndexPaths:indexPathArray];
        //刷新底部视图
        [weakSelf refreshBottomView];
    };
    
    //预览视图确认选择并发送
    photoBrowser.previewSendPhotoBlock = ^(NSMutableArray *retArray){
        //通过block返回
        _selectPhotoBlock(retArray);
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    photoBrowser.images = [NSArray arrayWithArray:retArray];
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - 完成选择照片
- (void)finishBtnClicked:(UIButton *)sender {
    if (!sender.isSelected) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        //选择照片完成
        [self finishedSelectedMyPhotos];
    }
}

#pragma mark - 返回选择后的照片
- (void)finishedSelectedMyPhotos {
    //完成选择图片
//    NSLog(@"finished select photo");
    NSMutableArray *retArray  = [NSMutableArray arrayWithCapacity:0];
    [_selectStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx<_selectStatusArray.count) {
            if ([obj integerValue]) {
                [retArray addObject:_dataArray[idx]];
            }
        }
    }];
    //得到选择后的图片 准备返回
    //通过代理返回
    [self.myDelegate finshedSelectedPhotos:retArray];
    //通过block返回
    _selectPhotoBlock(retArray);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Select All photos
- (void)selectAllPhotos:(UIButton *)sender {
//    NSLog(@"select all");
    UIButton *btn = (UIButton *)[self.view viewWithTag:11];
    UIButton *previewBtn = (UIButton *)[self.view viewWithTag:12];
    UILabel *label = (UILabel *)[self.view viewWithTag:13];
    if (!sender.isSelected) {
        [_selectStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _selectStatusArray[idx] = @(1);
        }];
        sender.selected = YES;
        btn.selected = YES;
        previewBtn.hidden = NO;
        label.text = [NSString stringWithFormat:@"已选择%ld张",_dataArray.count];
    }else {
        [_selectStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _selectStatusArray[idx] = @(0);
        }];
        sender.selected = NO;
        btn.selected = NO;
        previewBtn.hidden = YES;
        label.text = @"已选择0张";
    }
    [_collectionview reloadData];
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.bounds.size.width-15)/4, (self.view.bounds.size.width-15)/4);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(3, 3, 3, 3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 3;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCollectionViewCell *cell = (MyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectionviewcellid" forIndexPath:indexPath];
    
    ALAsset *asset = _dataArray[indexPath.row];
    UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
    [cell.imgView setImage:image];
    
    if ([_selectStatusArray[indexPath.row] integerValue]) {
        cell.gestureStatusView.hidden = NO;
        cell.selectStatusView.backgroundColor = kRGB(111, 190, 128);
    }else {
        cell.gestureStatusView.hidden = YES;
        cell.selectStatusView.backgroundColor = [UIColor clearColor];
    }
    
    cell.tag = 100+indexPath.row;
    return cell;
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //在cell中重写了UITouch的方法 这里的方法将不再被调用
}

#pragma mark - 点击选中了某个cell
- (void)didSelectedCellWithIndexP:(NSIndexPath *)indexPath {
    // 选中和非选中状态的判断
    if (!isMutiSelect) {
        if ([_selectStatusArray[indexPath.row] boolValue]) {
            _selectStatusArray[indexPath.row] = @(0);
        }else {
            _selectStatusArray[indexPath.row] = @(1);
        }
    }else {
        if (isClearMuti) {
            _selectStatusArray[indexPath.row] = @(0);
        }else {
            _selectStatusArray[indexPath.row] = @(1);
        }
    }
    
    [_collectionview reloadItemsAtIndexPaths:@[indexPath]];
    //刷新底部视图
    [self refreshBottomView];
}

#pragma mark - 刷新底部的视图
- (void)refreshBottomView {
    //底部按钮状态
    UIButton *btn = (UIButton *)[self.view viewWithTag:11];
    UIButton *previewBtn = (UIButton *)[self.view viewWithTag:12];
    UILabel *label = (UILabel *)[self.view viewWithTag:13];
    UIButton *allBtn = (UIButton *)[self.view viewWithTag:9];

    [_selectStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj integerValue]) {
            btn.selected = YES;
            previewBtn.hidden = NO;
            *stop = YES;
        }else {
            btn.selected = NO;
            previewBtn.hidden = YES;
        }
    }];
    
    __block NSInteger totalNum = 0;
    [_selectStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        totalNum+=[obj integerValue];
    }];
    label.text = [NSString stringWithFormat:@"已选择%ld张",totalNum];

    if (totalNum<_dataArray.count) {
        allBtn.selected = NO;
    }else {
        allBtn.selected = YES;
    }
}

#pragma mark - Notificatio:collection should scroll enable
- (void)collectionShouldScrollEnable:(NSNotification *)notify {
//    NSLog(@"notifi: %@",notify.object);
    BOOL info = [notify.object boolValue];
    if (info) {
        _collectionview.scrollEnabled = YES;
        isMutiSelect = NO;
    }else {
        _collectionview.scrollEnabled = NO;
        isMutiSelect = YES;
    }
}

#pragma mark - 清除所有选中的状态


#pragma mark - Notification:collection select a cell
- (void)collectionCellDidSelect:(NSNotification *)notif {
    id obj = [notif object];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)obj;
//        NSLog(@"___%@",dic);
        int startIndex = [dic[@"startIndex"] intValue];
        int endIndex = [dic[@"endIndex"] intValue];
        int max = MAX(startIndex, endIndex);
        int min = MIN(startIndex, endIndex);
        
        [_selectStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx>=min&&idx<=max) {
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:idx inSection:0];
                [self didSelectedCellWithIndexP:indexpath];
            }
        }];
    }else {
        NSIndexPath *indexpath = (NSIndexPath *)obj;
        if (indexpath.row<_dataArray.count) {
            if ([_selectStatusArray[indexpath.row] boolValue]) {
                isClearMuti = YES;
            }else {
                isClearMuti = NO;
            }
            [self didSelectedCellWithIndexP:indexpath];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    //开始移动 多选模式开启
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionShouldScrollEnable:) name:@"collectionScrollEnableNotif" object:nil];
    //点击选中一个cell
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionCellDidSelect:) name:@"collectionDidSelectCellNotif" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //移除特定通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"collectionScrollEnableNotif" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"collectionDidSelectCellNotif" object:nil];

}

- (void)dealloc {
    _collectionview.delegate = nil;
    _collectionview.dataSource = nil;
    _collectionview = nil;
    _dataArray = nil;
    _selectStatusArray = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
