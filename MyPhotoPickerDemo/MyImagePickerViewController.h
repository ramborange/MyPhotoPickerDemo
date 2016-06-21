//
//  MyImagePickerViewController.h
//  MyPhotoPickerDemo
//
//  Created by ramborange on 16/6/15.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^finishedSelectMyPhotos)(NSArray *selectedPhotos);

@class MyImagePickerViewController;
@protocol MyImagePickerViewDelegate <NSObject>

- (void)finshedSelectedPhotos:(NSArray *)selectedPhotos;

@end

@interface MyImagePickerViewController : UIImagePickerController

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) id<MyImagePickerViewDelegate> myDelegate;

@property (nonatomic, strong) finishedSelectMyPhotos selectPhotoBlock;

@end
