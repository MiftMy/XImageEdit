//
//  APFilterList.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/5.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APFilterList : NSObject

/*
 *  输入原图，返回滤镜model数据
 *
 */
+ (NSArray *)filterList:(UIImage *)img;

/**
 *      滤镜处理图片
 *      type:
    0 @"原图"
    1 @"美肤"
    2 @"童话
    3 @"温暖"
    4 @"冰冷"
    5 @"素描"
    6 @"明亮"
    7 @"蜡笔"
    8 @"黑白"
 *
 */
+ (UIImage *)imageFilter:(UIImage *)imgOrg WithType:(NSInteger)type;
@end
