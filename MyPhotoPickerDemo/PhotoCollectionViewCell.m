//
//  PhotoCollectionViewCell.m
//  MyPhotoPickerDemo
//
//  Created by ramborange on 16/6/16.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@interface PhotoCollectionViewCell() <UIScrollViewDelegate>
@end

@implementation PhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _photoView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_photoView setContentMode:UIViewContentModeScaleAspectFit];
        _photoView.userInteractionEnabled = YES;
        
//          UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizerAction:)];
//        [_photoView addGestureRecognizer:pinch];
//        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
        tap.numberOfTapsRequired = 2;
        [_photoView addGestureRecognizer:tap];
        
        _scrollview = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollview.delegate = self;
        _scrollview.maximumZoomScale = 5.0;
        _scrollview.userInteractionEnabled = YES;
        [self.contentView addSubview:_scrollview];
        
        [_scrollview addSubview:_photoView];
        
        _photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIView *topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 64)];
        topBarView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        topBarView.userInteractionEnabled = YES;
        [self.contentView addSubview:topBarView];
        
        _idxLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.bounds.size.width, 44)];
        [_idxLabel setTextColor:[UIColor whiteColor]];
        [_idxLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_idxLabel];
        
        _selectStatusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectStatusBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [_selectStatusBtn setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        _selectStatusBtn.frame = CGRectMake(self.bounds.size.width-40, 29, 26, 26);
        _selectStatusBtn.layer.cornerRadius = 13;
        _selectStatusBtn.layer.masksToBounds = YES;
        [_selectStatusBtn.layer setBorderWidth:2.0];
        [_selectStatusBtn.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.3].CGColor];
        [self.contentView addSubview:_selectStatusBtn];
        
    }
    
    self.contentView.frame = self.bounds;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return self;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize contentsize = scrollView.contentSize;
    contentsize.height = (_photoView.image.size.height*contentsize.width)/_photoView.image.size.width;
    scrollView.contentSize = contentsize;
    
    if (scrollView.contentSize.height>=self.bounds.size.height) {
        _photoView.center = CGPointMake(scrollView.contentSize.width/2, scrollView.contentSize.height/2);
    }else {
        _photoView.center = CGPointMake(scrollView.contentSize.width/2, scrollView.bounds.size.height/2);
    }
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoView;
}

#pragma mark - 双击手势
- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tapGesture {
    if (_scrollview.zoomScale>1.0) {
        [_scrollview setZoomScale:1.0 animated:YES];
    }else {
        [_scrollview setZoomScale:2.5 animated:YES];
    }
}

#pragma mark - 捏合手势
- (void)pinchGestureRecognizerAction:(UIPinchGestureRecognizer *)pinchGesture {
    float scale = pinchGesture.scale;
//    NSLog(@"pinch scale: %f",scale);

    if (scale>=1) {
        _photoView.transform = CGAffineTransformMakeScale(pinchGesture.scale, pinchGesture.scale);
    }
    
}


@end
