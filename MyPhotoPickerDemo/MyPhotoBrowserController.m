//
//  MyPhotoBrowserController.m
//  MyPhotoPickerDemo
//
//  Created by ramborange on 16/6/16.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import "MyPhotoBrowserController.h"
#import "PhotoCollectionViewCell.h"

#import <AssetsLibrary/AssetsLibrary.h>

#define kRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define kRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface MyPhotoBrowserController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSInteger currentPhotoIdx;
}
@property (nonatomic, strong) UICollectionView *collectionview;

@property (nonatomic, strong) NSMutableArray *selectStatusArray;
@end

@implementation MyPhotoBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    NSLog(@"images count:%ld",_images.count);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionview = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionview.pagingEnabled = YES;
    _collectionview.delegate = self;
    _collectionview.dataSource = self;
    _collectionview.showsHorizontalScrollIndicator = NO;
    _collectionview.userInteractionEnabled = YES;
    _collectionview.maximumZoomScale = 2.0;
    _collectionview.minimumZoomScale = 1.0;
    _collectionview.backgroundColor = [UIColor blackColor];
    _collectionview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_collectionview];
    [_collectionview registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"collectionviewcellid"];
    
   
    UIView *bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    bottomBarView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:bottomBarView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"已选择%ld张",_images.count];
    label.tag = 31;
    label.textColor = [UIColor whiteColor];
    [bottomBarView addSubview:label];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(15, 10, 50, 24);
    backBtn.backgroundColor =  kRGBA(0, 101, 255, 0.75);
    backBtn.layer.cornerRadius = 3;
    backBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    backBtn.layer.masksToBounds = YES;
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:backBtn];

    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    sendBtn.backgroundColor = kRGBA(0, 101, 255, 0.75);
    sendBtn.layer.cornerRadius = 3;
    sendBtn.layer.masksToBounds = YES;
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendBtn.frame = CGRectMake(self.view.bounds.size.width-65, 10, 50, 24);
    sendBtn.tag =32;
    [sendBtn addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:sendBtn];
    
    _selectStatusArray = [NSMutableArray arrayWithCapacity:0];
    [_images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _selectStatusArray[idx] = @(1);
    }];
   
}

#pragma mark - 发送图片
- (void)sendBtnClicked {
    //完成选择图片
    NSLog(@"finished select photo");
    
    [self dismissViewControllerAnimated:NO completion:^{
        NSMutableArray *retArray  = [NSMutableArray arrayWithCapacity:0];
        [_selectStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx<_selectStatusArray.count) {
                if ([obj integerValue]) {
                    [retArray addObject:_images[idx]];
                }
            }
        }];
        //得到选择后的图片 准备返回
        _previewSendPhotoBlock(retArray);
    }];
}

#pragma mark - 返回
- (void)goBack {
    _previewSelectedStatusBlock(_selectStatusArray);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 判断当前的图片的序号
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger idx = scrollView.contentOffset.x/_collectionview.bounds.size.width;
    currentPhotoIdx = idx;
    
    //    NSLog(@"%f  %ld",scrollView.contentOffset.x,idx);
}

#pragma mark - 屏幕发生旋转
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // Update the flowLayout's size to the new orientation's size
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)_collectionview.collectionViewLayout;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        flow.itemSize = CGSizeMake(_collectionview.frame.size.width, _collectionview.frame.size.height);
    } else {
        flow.itemSize = CGSizeMake(_collectionview.frame.size.width, _collectionview.frame.size.height);
    }
    _collectionview.collectionViewLayout = flow;
    [_collectionview.collectionViewLayout invalidateLayout];
    
    // Get the currently visible cell
    PhotoCollectionViewCell *currentCell = (PhotoCollectionViewCell*)[_collectionview cellForItemAtIndexPath:[NSIndexPath indexPathForRow:currentPhotoIdx inSection:0]];
    
    // Resize the currently index to the new flow's itemSize
    CGRect frame = currentCell.frame;
    frame.size = flow.itemSize;
    currentCell.frame = frame;
    
    // Keep the collection view centered by updating the content offset
    CGPoint newContentOffset = CGPointMake(currentPhotoIdx * frame.size.width, 0);
    _collectionview.contentOffset = newContentOffset;

}

#pragma mark - UICollectionviewFlowLayout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectionviewcellid" forIndexPath:indexPath];
    ALAsset *asset = _images[indexPath.row];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:representation.fullResolutionImage];
    [cell.photoView setImage:image];
    cell.idxLabel.text = [NSString stringWithFormat:@"%ld/%ld",indexPath.row+1,_images.count];
    if ([_selectStatusArray[indexPath.row] integerValue]) {
        [cell.selectStatusBtn setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            cell.selectStatusBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
           [UIView animateWithDuration:0.1 animations:^{
               cell.selectStatusBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
           }];
        }];
        
    }else {
        [cell.selectStatusBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    //当有放大后的大图 滑动过来的时候 还原之前大图的比例
    if (cell.scrollview.zoomScale>1) {
        [cell.scrollview setZoomScale:1.0 animated:YES];
    }
    
    [cell.selectStatusBtn addTarget:self action:@selector(selectStatusChaned:) forControlEvents:UIControlEventTouchUpInside];
        
    return cell;
}


- (void)selectStatusChaned:(UIButton *)sender {
//    NSLog(@"btn clickd");
    if ([_selectStatusArray[currentPhotoIdx] integerValue]) {
        _selectStatusArray[currentPhotoIdx] = @(0);
    }else {
        _selectStatusArray[currentPhotoIdx] = @(1);
    }
    [_collectionview reloadData];

    UILabel *label = (UILabel *)[self.view viewWithTag:31];
    __block NSInteger selectNum = 0;
    [_selectStatusArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        selectNum+=[obj integerValue];
    }];
    label.text = [NSString stringWithFormat:@"已选择%ld张",selectNum];
    UIButton *sendBtn = (UIButton *)[self.view viewWithTag:32];
    if (selectNum) {
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendBtn.enabled = YES;
    }else {
        sendBtn.enabled = NO;
        [sendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    _collectionview.delegate = nil;
    _collectionview.dataSource = nil;
    _collectionview = nil;
    _images = nil;
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
