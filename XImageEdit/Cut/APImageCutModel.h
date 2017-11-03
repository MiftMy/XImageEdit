//
//  APImageCutModel.h
//  AreoxPlay
//
//  Created by mifit on 2017/8/31.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface APImageCutModel : NSObject
@property (nonatomic, copy) NSString *scaleName;
@property (nonatomic, copy) NSString *iamgeName;
@property (nonatomic, copy) NSString *iamgeSelName;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) BOOL isSel;
@end
