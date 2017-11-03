//
//  APImageLabel.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/7.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APImageLabel : UIView
@property (nonatomic, assign) BOOL isSel;

@property (nonatomic, copy) void (^delBlock)(void);
@property (nonatomic, copy) void (^editBlock)(void);

@property (nonatomic, copy) void (^tapType)(NSInteger type);
- (void)setTextFontName:(NSString *)name;
- (void)setTextColor:(UIColor *)color;
- (void)setTextColorAlpha:(CGFloat)alpha;
- (void)nextAlignment;
- (NSTextAlignment)textAlignment;
- (void)setText:(NSString *)str attr:(NSDictionary *)dic;
- (void)setTextAttr:(NSDictionary *)dic;
@end
             
