//
//  MyCollectionViewCell.m
//  MyPhotoPickerDemo
//
//  Created by ramborange on 16/6/15.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import "MyCollectionViewCell.h"

#define kRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface MyCollectionViewCell()
{
    BOOL isSendNotify;
    CGPoint startPoint;
    NSInteger previewIndex;
}

@end

@implementation MyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_imgView];
        
        _gestureStatusView = [[UIView alloc] initWithFrame:self.bounds];
        _gestureStatusView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.contentView addSubview:_gestureStatusView];
        
        _selectStatusView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-22, 2, 20, 20)];
        _selectStatusView.layer.cornerRadius = 10;
        _selectStatusView.layer.masksToBounds = YES;
        [self.contentView addSubview:_selectStatusView];
        
        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-20, 4, 16, 16)];
        [circleView.layer setBorderWidth:1.0];
        [circleView.layer setBorderColor:[UIColor whiteColor].CGColor];
        circleView.layer.cornerRadius = 8;
        circleView.layer.masksToBounds = YES;
        [self.contentView addSubview:circleView];
        
    }
    return self;
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.contentView];
//    NSLog(@"index:%ld   %@",self.tag-100,[NSValue valueWithCGPoint:point]);
    startPoint = point;
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.tag-100 inSection:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionDidSelectCellNotif" object:indexpath];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touch moved");
    CGPoint point = [[touches anyObject] locationInView:self.contentView];
    CGPoint prePoint = [[touches anyObject] previousLocationInView:self.contentView];
    if (prePoint.x!=point.x) {
        //判断是否处于水平滑动状态 即多选时 禁止父视图的滚动
        if (!isSendNotify) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionScrollEnableNotif" object:@(NO)];
            isSendNotify = YES;
        }
    }
    
    CGSize itemSize = self.bounds.size;
    NSInteger startIndex = self.tag-100;//起始cell位置
    
    float touchX = 0;//水平的总移动距离
    float touchY = 0;//垂直
    if (point.x) {
        touchX = point.x;
    }else {
        touchX = point.x-startPoint.x;
    }
    if (point.y) {
        touchY = point.y;
    }else {
        touchY = point.y-startPoint.y;
    }
    
    NSInteger xNum = ceilf(touchX/itemSize.width); //row number
    if (xNum>0) {
        xNum = MIN(4, xNum);
    }else {
        xNum = MAX(-2, xNum);
    }
    NSInteger yNum = ceilf(touchY/itemSize.height); //colum number
    
    NSInteger addNum = 0;
    addNum = (yNum-1)*4+(xNum-1);//新增加的被移动选中的cell
   
//    NSLog(@"x:%ld y:%ld",xNum,yNum);
//    NSLog(@"addNum:%ld",addNum);
    
    NSInteger endIndex = startIndex+addNum;    
    
    if (endIndex!=previewIndex) {

        
        NSDictionary *notifyDic = [NSDictionary dictionaryWithObjects:@[@(startIndex),@(endIndex)] forKeys:@[@"startIndex",@"endIndex"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionDidSelectCellNotif" object:notifyDic];
    }
   
    previewIndex = endIndex;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touchesEnded");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionScrollEnableNotif" object:@(YES)];
    isSendNotify = NO;
    previewIndex = 0;
}

@end
//