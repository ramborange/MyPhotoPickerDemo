//
//  MyPhotoBrowserController.h
//  MyPhotoPickerDemo
//
//  Created by ramborange on 16/6/16.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedStatusBlock)(NSMutableArray *selectStatus);

typedef void(^sendPhotoInPreviewBlock)(NSMutableArray *retArray);

@interface MyPhotoBrowserController : UIViewController

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) SelectedStatusBlock previewSelectedStatusBlock;

@property (nonatomic, strong) sendPhotoInPreviewBlock previewSendPhotoBlock;

@end
