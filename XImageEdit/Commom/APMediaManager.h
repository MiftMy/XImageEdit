//
//  APMediaManager.h
//  AreoxPlay
//
//  Created by mifit on 2017/7/27.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset, AVPlayerItem, AVURLAsset;

@interface APMediaManager : NSObject

+ (APMediaManager *)shareInstance;

/// 获取areox的图片    array数据类型：APMediaLibaryModel
+ (void)imageFromAssert:(void (^)(NSArray *list))block;

/// 获取相册最新一张图
+ (void)lastestPhoto:(void(^)(UIImage *))block;

/// 从PHAsset获取图片
- (void)imageFromAsset:(PHAsset *)asset size:(CGSize)size tag:(NSInteger)tag  completed:(void(^)(UIImage *item, NSInteger tag))block;

/// 保存图片
- (void)saveImage:(UIImage *)img complete:(void(^)(BOOL isOK, NSString *error))block;




/// 获取视频的首图
+ (UIImage *)thumbnailFromPath:(NSString *)videoURL;

/// 获取视频的首图
+ (UIImage *)thumbnailFromURL:(NSURL *)videoURL;

+ (UIImage *)thumbnailFromAsset:(AVURLAsset *)asset;

/// 获取areox的视频    array数据类型：APMediaLibaryModel
+ (void)videoFromAssert:(void (^)(NSArray *list))block;

/// 获取缓存图片视频文件    array数据类型：APMediaLibaryModel
+ (NSArray *)videoInCache;

/// 从PHAsset获取视频的AVPlayerItem
- (void)playItemFromAsset:(PHAsset *)asset completed:(void(^)(AVPlayerItem *item))block;

/// 保存视频
- (void)saveVideo:(NSURL *)url completed:(void (^)(BOOL isOK, NSString *error))block;

@end
