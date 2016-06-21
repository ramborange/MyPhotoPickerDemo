//
//  MyCollectionViewCell.h
//  MyPhotoPickerDemo
//
//  Created by ramborange on 16/6/15.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MyCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UIImageView *selectStatusView;

@property (nonatomic, strong) UIView *gestureStatusView;

@end
