//
//  APPanView.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

//手势view
@interface APGestureView : UIView
//单指
@property (nonatomic, copy) void (^panDrawGRChanged)(NSInteger state, CGPoint pint);

//双指
@property (nonatomic, copy) void (^panGRChanged)(NSInteger state, CGPoint pint, NSInteger touches);

//缩放
@property (nonatomic, copy) void (^pinchGRChanged)(NSInteger state,CGFloat scale, NSInteger touched);

//旋转
@property (nonatomic, copy) void (^rotationGRChanged)(NSInteger state,CGFloat rotation);
@end
