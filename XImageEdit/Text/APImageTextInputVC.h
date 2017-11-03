//
//  APImageTextInputVC.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/7.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APImageTextInputVC : UIViewController
@property (nonatomic, assign) BOOL isAdd;
@property (nonatomic, copy) NSString *defalutStr;
@property (nonatomic, copy) void (^applyBlock)(NSString *str);
@end
