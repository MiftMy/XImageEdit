//
//  APDrawModel.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APDrawPathModel;

@interface APDrawModel : NSObject <NSCopying, NSMutableCopying>
@property (nonatomic, strong) APDrawPathModel *pathModel;
@property (nonatomic, copy) NSString *strokeColor;//线颜色，hex
//@property (nonatomic, copy) NSString *fillColor;//填充颜色 hex
@property (nonatomic, assign) CGSize paintSize;//画布大小
@property (nonatomic, assign) BOOL isEraser;     //是否擦除


@end
