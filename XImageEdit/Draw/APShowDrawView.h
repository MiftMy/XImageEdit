//
//  APImageDrawboard.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APDrawModel;
//只显示已画好的界面
@interface APShowDrawView : UIView

@property (nonatomic, strong) NSMutableArray *stepList;
@property (nonatomic, assign) NSInteger activeStep;

- (void)addStep:(APDrawModel *)model;
@end
