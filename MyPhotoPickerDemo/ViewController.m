//
//  ViewController.m
//  MyPhotoPickerDemo
//
//  Created by ramborange on 16/6/14.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import "ViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "MyImagePickerViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,MyImagePickerViewDelegate>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) ALAssetsLibrary *library;

@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) NSMutableArray *tableviewDataArray;
@end


@implementation selectPhoto

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllPhoto)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _images = [NSMutableArray arrayWithCapacity:0];
    _tableviewDataArray = [NSMutableArray arrayWithCapacity:0];
    
    _tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableview];
    _tableview.tableFooterView = [UIView new];
    
    _library = [[ALAssetsLibrary alloc] init];
    [_library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        if (group!=nil) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                NSLog(@"type:%@",[result valueForProperty:ALAssetPropertyType]);
//                NSLog(@"result:%@",result);
                if (result!=nil) {
                    ALAsset *asset = [[ALAsset alloc] init];
                    asset = result;
                    [_images addObject:result];
                }else {
                    [_tableview reloadData];
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"error:%@",error);
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableviewDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell== nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    if (_tableviewDataArray.count) {
        ALAsset *asset = _tableviewDataArray[indexPath.row];
        if (asset!=nil) {
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
            
            [cell.imageView setImage:image];
            cell.textLabel.text = type;
            cell.detailTextLabel.text = url.absoluteString;
            cell.detailTextLabel.numberOfLines = 0;
        }
    }
    
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)clearAllPhoto {
    _tableviewDataArray = [NSMutableArray arrayWithCapacity:0];
    [_tableview reloadData];
}

- (void)selectPhoto {
    MyImagePickerViewController *pickerController = [[MyImagePickerViewController alloc] init];

    BOOL ret = [MyImagePickerViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if (ret) {
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else {
        NSLog(@"不支持相机");
    }
    
    pickerController.dataArray = _images;
    pickerController.myDelegate = self;
    pickerController.delegate = self;
    
    pickerController.selectPhotoBlock = ^(NSArray *selectedPhotos) {
        [_tableviewDataArray addObjectsFromArray:selectedPhotos];
        [_tableview reloadData];
    };
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - MyImagePickerView Delegate
- (void)finshedSelectedPhotos:(NSArray *)selectedPhotos {
    //用代理和block都可以 上面选择了block 这里就注释掉
//    [_tableviewDataArray addObjectsFromArray:selectedPhotos];
//    [_tableview reloadData];
}

#pragma mark - UIPhotoPickerController Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    NSLog(@"info:%@",info);
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    
//    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
//    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)
//     {
//         ALAssetRepresentation *rep = [asset defaultRepresentation];
//         Byte *buffer = (Byte*)malloc(rep.size);
//         NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
//         NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
//         
//     }failureBlock:^(NSError *err) {
//        NSLog(@"Error: %@",[err localizedDescription]);
//     }];
    
    
    selectPhoto *p = [[selectPhoto alloc] init];
    p.image = image;
    p.url = url;
    
    [self.images addObject:p];
    [_tableview reloadData];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
*/

-(void)dealloc {
    _tableview.delegate = nil;
    _tableview.dataSource = nil;
    _tableview = nil;
    _tableviewDataArray = nil;
    _images = nil;
    _library = nil;
}
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
