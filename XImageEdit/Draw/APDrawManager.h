//
//  APDrawManager.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APDrawModel, APDrawPathModel;

@interface APDrawManager : NSObject
+ (UIImage *)imageFromModel:(APDrawModel *)model scale:(CGFloat)scale;
+ (UIImage *)imageFromModels:(NSArray *)list scale:(CGFloat)scale;
/**
 *  依据model给图片添加画笔内容
 * @param   model       绘画内容model
 * @param   imgOrg      需要绘制的图
 * @param   scale       图片宽：图片显示在Imageview的坐标 model的paintSize必须要和图片的等比例，不然跟你想象的不一样
 * @return
 */
+ (UIImage *)imageFromModel:(APDrawModel *)model orgImage:(UIImage *)imgOrg scale:(CGFloat)scale;

/**
 *  依据model给图片添加画笔内容
 * @param   list        绘画内容model的数组
 * @param   imgOrg      需要绘制的图
 * @param   scale       图片宽：图片显示在Imageview的坐标 model的paintSize必须要和图片的等比例，不然跟你想象的不一样
 * @return
 */
+ (UIImage *)imageFromModels:(NSArray *)list orgImage:(UIImage *)imgOrg scale:(CGFloat)scale;

+ (UIBezierPath *)pathFromModel:(APDrawPathModel *)model;
@end
