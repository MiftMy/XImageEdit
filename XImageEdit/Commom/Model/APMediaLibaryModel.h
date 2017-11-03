//
//  APMediaLibaryModel.h
//  AreoxPlay
//
//  Created by mifit on 16/8/19.
//  Copyright © 2016年 Mifit. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage,PHAsset;

/*
 *  相册model，包括图片、视频、音频
 */
@interface APMediaLibaryModel : NSObject
@property (nonatomic,assign) BOOL isSel;//collection使用，是否选中
@property (nonatomic,assign) BOOL isVideo;//是否视频
@property (nonatomic,strong) PHAsset *asset;//相册对象
@property (nonatomic,strong) UIImage *bgImg;//背景图
@property (nonatomic,copy) NSString *name;//名称
@property (nonatomic,copy) NSString *url;//地址
@property (nonatomic,copy) NSString *videoTime;//时间 01:01
@property (nonatomic,assign) NSTimeInterval totalTime;//总时间 61.0
@property (nonatomic,assign) NSTimeInterval beginTime;//开始时间 0.0
@property (nonatomic,assign) NSTimeInterval endTime;//结束时间  61.0
@end
