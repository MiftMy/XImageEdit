//
//  SGInfoAlert.m
//
//  Created by Azure_Sagi on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SGInfoAlert : UIView

/*  自动消失提示框,不会隐藏之前弹出的提示框
 * @param info      为提示信息
 * @param color     字体颜色
 * @param view      view是为消息框的superView（推荐Tabbarcontroller.view)
 * @param vertical  为垂直方向上出现的位置 从 取值 0 ~ 1。
 */
+ (void)showInfo:(NSString*)info 
         bgColor:(CGColorRef)color
          inView:(UIView*)view 
        vertical:(float)height;

/*  自动消失提示框,会隐藏之前弹出的提示框，与上面的方法可同时存在，与下面的不能同时存在
 * @param info      为提示信息
 * @param color     字体颜色
 * @param view      view是为消息框的superView（推荐Tabbarcontroller.view)
 * @param vertical  为垂直方向上出现的位置 从 取值 0 ~ 1。
 */
+ (void)showInfo_3:(NSString*)info
           bgColor:(CGColorRef)color
            inView:(UIView*)view
          vertical:(float)height;


/*  显示提示框，不会自动消失。与下面dismissInfo配对。
 * @param info      为提示信息
 * @param color     字体颜色
 * @param view      view是为消息框的superView（推荐Tabbarcontroller.view)
 * @param vertical  为垂直方向上出现的位置 从 取值 0 ~ 1。
 */
+ (void)showInfo_2:(NSString*)info
         bgColor:(CGColorRef)color
          inView:(UIView*)view
        vertical:(float)height;

/*  移除提示框
 */
+ (void)dismissInfo;


@end
