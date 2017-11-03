//
//  APMediaManager.m
//  XMPhotoPlay
//
//  Created by mifit on 2017/7/27.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APMediaManager.h"
#import <Photos/Photos.h>
#import "APMediaLibaryModel.h"

@interface APMediaManager()
<
PHPhotoLibraryChangeObserver
>
{
    BOOL isAddAsset;
}
@property (nonatomic, strong) PHCachingImageManager *imageManager;//相册管理对象
@property (nonatomic, strong) PHPhotoLibrary *photoLibaray;//相册管理对象

//保存结果
@property (nonatomic, copy) void (^saveResultBlock)(BOOL isOK, NSString *error);
@end
@implementation APMediaManager
- (APMediaManager *)init {
    if (self = [super init]) {
        isAddAsset = NO;
    }
    return self;
}
- (void)dealloc {
    if (_photoLibaray) {
        [_photoLibaray unregisterChangeObserver:self];
    }
}
- (PHPhotoLibrary *)photoLibaray {
    if (!_photoLibaray) {
        _photoLibaray = [PHPhotoLibrary sharedPhotoLibrary];
        [_photoLibaray registerChangeObserver:self];
    }
    return _photoLibaray;
}
- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [PHCachingImageManager new];
    }
    return _imageManager;
}
+ (APMediaManager *)shareInstance {
    static APMediaManager *shareBT = nil;
    static dispatch_once_t onceTokenBT;
    dispatch_once(&onceTokenBT, ^{
        if (!shareBT) {
            shareBT = [[APMediaManager alloc]init];
        }
    });
    return shareBT;
}

+ (void)XMPhotoAlbum:(void(^)(PHAssetCollection *))block {
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    PHAssetCollection *col = nil;
    for (PHAssetCollection *accc in userAlbums) {
        if ([accc.localizedTitle isEqualToString:@"XMPhoto"]) {
            col = accc;
        }
    }
    if (!col) {
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"XMPhoto"];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            PHAssetCollection *col = nil;
            for (PHAssetCollection *accc in userAlbums) {
                if ([accc.localizedTitle isEqualToString:@"XMPhoto"]) {
                    col = accc;break;
                }
            }
            if (col) {
                if (block) {
                    block(col);
                }
            } else {
                if (block) {
                    block(nil);
                }
            }
        }];
    } else {
        if (block) {
            block(col);
        }
    }
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    if (isAddAsset) {
        if (self.saveResultBlock) {
            self.saveResultBlock(YES, nil);
        }
        isAddAsset = NO;
    }
    self.saveResultBlock = nil;
}

#pragma mark - image
+ (void)lastestPhoto:(void(^)(UIImage *))block {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        /// 按创建日期排序
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *albumsPic = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        if (albumsPic.count > 0) {
            PHAsset *asset = albumsPic[albumsPic.count-1];
            PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
            [imageManager requestImageForAsset:asset
                                    targetSize:CGSizeMake(66, 66)
                                   contentMode:PHImageContentModeAspectFill
                                       options:nil
                                 resultHandler:^(UIImage *result, NSDictionary *info) {
                                     // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                     if (block) {
                                         block(result);
                                     }
                                 }];
        }
    }
}

- (void)imageFromAsset:(PHAsset *)asset size:(CGSize)size tag:(NSInteger)tag  completed:(void(^)(UIImage *item, NSInteger tag))block {
    [self.imageManager requestImageForAsset:asset
                                 targetSize:size
                                contentMode:PHImageContentModeAspectFit
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                  NSInteger value = [[info valueForKey:@"PHImageResultIsDegradedKey"]integerValue];
                                  if ( value == 0){
                                      if (block) {
                                          block(result, tag);
                                      }
                                  }
                              }];
}
+ (void)imageFromAssert:(void (^)(NSArray *list))block {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType=1"];
        //PHFetchResult *user = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[@"XMPhoto"] options:options];
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        NSMutableArray *list = nil;
        for (PHAssetCollection *accc in userAlbums) {
            if ([accc.localizedTitle isEqualToString:@"XMPhoto"]) {
                list = [NSMutableArray array];
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:accc options:options];
                for (PHAsset *asset in result) {
                    APMediaLibaryModel *model = [APMediaLibaryModel new];
                    model.isVideo = NO;
                    model.isSel = NO;
                    model.asset = asset;
                    [list addObject:model];
                }
                NSLog(@"Getted image");
                break;
            }
        }
        if (block) {
            block(list);
        }
    } else {
        if (block) {
            block(nil);
        }
    }
}

- (void)saveImage:(UIImage *)img complete:(void(^)(BOOL isOK, NSString *error))block {
    if (!img) {
        if (block) {
            block(NO, @"Image is empty");
        }
    }
    __weak typeof(self) weakSelf = self;
    [APMediaManager XMPhotoAlbum:^(PHAssetCollection *col) {
        if (col) {
            [weakSelf addCustomAsset:img collection:col completionHandler:^{
                NSLog(@"Send image to save");
                self.saveResultBlock = block;
                isAddAsset = YES;
            } failture:^(NSString * _Nonnull ff) {
                if (block) {
                    block(NO, @"save fail");
                }
            }];
        } else {
            if (block) {
                block(NO, @"save fail");
            }
        }
    }];
}

- (void)addCustomAsset:(UIImage *)image
            collection:(PHAssetCollection *)collection
     completionHandler:(void (^)(void))successBlock
              failture:(void (^)(NSString * _Nonnull))failtureBlock {
    
    [self.photoLibaray performChanges:^{
        if([collection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
            PHAssetChangeRequest * assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            PHAssetCollectionChangeRequest * groupChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            [groupChangeRequest addAssets:@[assetChangeRequest.placeholderForCreatedAsset]];
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {//成功
            successBlock();return;
        }
        failtureBlock(error.localizedDescription);
    }];
}

#pragma mark - video
+ (UIImage *)thumbnailFromPath:(NSString *)videoURL {
    NSURL *url = [NSURL fileURLWithPath:videoURL];
    return [APMediaManager thumbnailFromURL:url];
}

//依据url获取图片
+ (UIImage *)thumbnailFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    return [self thumbnailFromAsset:asset];
}

+ (UIImage *)thumbnailFromAsset:(AVURLAsset *)asset {
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

- (void)playItemFromAsset:(PHAsset *)asset completed:(void(^)(AVPlayerItem *item))block {
    PHCachingImageManager *manager = [PHCachingImageManager new];
    [manager requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (block) {
            block(playerItem);
        }
    }];
}

- (void)saveVideo:(NSURL *)url completed:(void (^)(BOOL isOK, NSString *))block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //创建相册
        __weak typeof(self) weakSelf = self;
        [APMediaManager XMPhotoAlbum:^(PHAssetCollection *col) {
            if (col) {
                [weakSelf addCustomAsset2:url collection:col completionHandler:^{
                    NSLog(@"Send video to save.");
                    weakSelf.saveResultBlock = block;
                    isAddAsset = YES;
                } failture:^(NSString * _Nonnull str) {
                    if (block) {
                        block(NO, @"save fail");
                    }
                }];
            }
        }];
    });
}

- (void)addCustomAsset2:(NSURL *)url
             collection:(PHAssetCollection *)collection
      completionHandler:(void (^)(void))successBlock
               failture:(void (^)(NSString * _Nonnull))failtureBlock {
    
    [self.photoLibaray performChanges:^{
        if([collection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
            PHAssetChangeRequest * assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            PHAssetCollectionChangeRequest * groupChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            [groupChangeRequest addAssets:@[assetChangeRequest.placeholderForCreatedAsset]];
        }
    }completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {//成功
            successBlock();return;
        }
        failtureBlock(error.localizedDescription);
    }];
}



+ (void)videoFromAssert:(void (^)(NSArray *list))block {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        /// 按创建日期排序
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType=2"];
        
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        NSMutableArray *list = nil;
        for (PHAssetCollection *accc in userAlbums) {
            if ([accc.localizedTitle isEqualToString:@"XMPhoto"]) {
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:accc options:options];
                list = [NSMutableArray arrayWithCapacity:result.count];
                for (PHAsset *asset in result) {
                    APMediaLibaryModel *model = [APMediaLibaryModel new];
                    model.isVideo = YES;
                    model.isSel = NO;
                    model.asset = asset;
                    model.beginTime = 0.0;
                    NSInteger total = (NSInteger)asset.duration;
                    model.endTime = total;
                    model.totalTime = total;
                    NSInteger h = 0,m = 0,s = 0;
                    s = total % 60; total /= 60;
                    m = total % 60; total /= 60;
                    h = total % 60;
                    if (h == 0) {
                        model.videoTime = [NSString stringWithFormat:@"%02d:%02d",m,s];
                    } else {
                        model.videoTime = [NSString stringWithFormat:@"%d:%02d:%02d",h,m,s];
                    }
                    [list addObject:model];
                }
                NSLog(@"getted video");
            }
        }
        if (block) {
            block(list);
        }
    } else {
        if (block) {
            block(nil);
        }
    }
}

//获取缓存图片视频文件
+ (NSArray *)videoInCache {
    NSString *cachPath = NSTemporaryDirectory();
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    NSMutableArray *list = nil;
    for (NSString *file in files) {
        NSString *path = [cachPath stringByAppendingPathComponent:file];
        if ([path hasSuffix:@"mp4"]) {
            APMediaLibaryModel *model = [self modelFromURL:path];
            if (!list) {
                list = [NSMutableArray array];
            }
            [list addObject:model];
        }
    };
    return list;
}

+ (APMediaLibaryModel *)modelFromURL:(NSString *)strURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:strURL] options:nil];
    NSInteger total = asset.duration.value / asset.duration.timescale;
    APMediaLibaryModel *model = [APMediaLibaryModel new];
    model.isVideo = YES;
    model.isSel = NO;
    model.url = strURL;
    model.totalTime = total;
    model.endTime = total;
    model.beginTime = 0.0;
    NSInteger h = 0,m = 0,s = 0;
    s = total % 60; total /= 60;
    m = total % 60; total /= 60;
    h = total % 60;
    if (h == 0) {
        model.videoTime = [NSString stringWithFormat:@"%02ld:%02ld",(long)m,(long)s];
    } else {
        model.videoTime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)h,(long)m,(long)s];
    }
    return model;
}



@end
