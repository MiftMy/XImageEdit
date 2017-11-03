//
//  APCalibrationView.h
//  XMGestureFallthrough
//
//  Created by mifit on 2017/9/25.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 *  左右各45度滑动条
 */
@interface APCalibrationView : UIView
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, copy) void (^valueChangedBlock)(NSInteger val);
@end
