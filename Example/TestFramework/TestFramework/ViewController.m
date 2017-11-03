//
//  ViewController.m
//  XMImageEdit
//
//  Created by mifit on 2017/10/30.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "ViewController.h"
#import "APMediaLibaryModel.h"
#import "APImageEditVC.h"
#import <Photos/Photos.h>

@interface ViewController ()
{
    PHAssetCollection *collection;
    UIImage *temImg;
}
@property (weak, nonatomic) IBOutlet UIImageView *orgImg;
@property (weak, nonatomic) IBOutlet UIImageView *dealImg;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self lastestPhoto];
}

- (IBAction)editImage:(id)sender {
    APImageEditVC *vc = [[UIStoryboard storyboardWithName:@"APImageEdit" bundle:nil]instantiateViewControllerWithIdentifier:@"APImageEditVC"];
    vc.orgImg = temImg;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)lastestPhoto {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        /// 按创建日期排序
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *albumsPic = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        if (albumsPic.count > 0) {
            PHAsset *asset = albumsPic[albumsPic.count-1];
            PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
            [imageManager requestImageForAsset:asset
                                    targetSize:CGSizeMake(1000, 1000)
                                   contentMode:PHImageContentModeAspectFill
                                       options:nil
                                 resultHandler:^(UIImage *result, NSDictionary *info) {
                                     temImg = result;
                                     self.orgImg.image = result;
             }];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
