//
//  PhotoCollectionViewCell.h
//  MyPhotoPickerDemo
//
//  Created by ramborange on 16/6/16.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *idxLabel;

@property (nonatomic, strong) UIImageView *photoView;

@property (nonatomic, strong) UIButton *selectStatusBtn;

@property (nonatomic, strong) UIScrollView *scrollview;//图片放大放小

@end
