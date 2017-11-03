//
//  APImageTextFontModel.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/6.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APImageTextFontModel : NSObject
@property (nonatomic, copy) NSString *showText;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) BOOL isSel;
@property (nonatomic, assign) NSInteger fontSize;
@end
