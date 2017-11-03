//
//  APImageTextList.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/6.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageTextList.h"
#import "APImageTextFontModel.h"

@implementation APImageTextList

+ (NSArray *)fontListMode {
    NSMutableArray *temList = [NSMutableArray arrayWithCapacity:6];
    for (NSInteger indx = 0; indx < 6; indx ++) {
        APImageTextFontModel *model = [APImageTextFontModel new];
        model.fontSize = 12;
        model.showText = @"字体";
        model.isSel = NO;
        switch (indx) {
            case 0:
                model.isSel = YES;
                model.fontName = @"MIMIJW";
                break;
            case 1:
                model.fontName = @"方圆硬笔行书简";
                break;
            case 2:
                model.fontName = @"Zzuo";
                break;
            case 3:
                model.fontName = @"quietsky";
                break;
            case 4:
                model.fontName = @"HanziPen SC";
                break;
            case 5:
                model.fontName = @"方正悬针篆变体";
                break;
            default:
                break;
        }
        [temList addObject:model];
    }
    return temList;
}

@end
